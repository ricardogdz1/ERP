class PurchaseOrder < ApplicationRecord
  # Constantes
  STATUSES = %w[draft pending approved sent partial completed cancelled].freeze
  PAYMENT_TERMS = %w[cash 15_days 30_days 45_days 60_days].freeze
  
  # Associações
  belongs_to :contact # fornecedor
  belongs_to :product
  belongs_to :user
  
  # Validações
  validates :order_number, presence: true, uniqueness: true
  validates :order_date, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :payment_terms, inclusion: { in: PAYMENT_TERMS }, allow_blank: true
  
  # Callbacks
  before_validation :generate_order_number, on: :create
  before_save :calculate_totals
  after_update :check_delivery_completion
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :recent, -> { order(order_date: :desc) }
  scope :by_supplier, ->(contact_id) { where(contact_id: contact_id) }
  scope :overdue, -> { where('expected_delivery_date < ? AND status NOT IN (?)', Date.current, ['completed', 'cancelled']) }
  
  # Métodos públicos
  def supplier
    contact
  end
  
  def approve!
    update!(status: 'approved', approved_at: Time.current)
  end
  
  def cancel!
    return false if status == 'completed'
    update!(status: 'cancelled')
  end
  
  def receive_items(quantity_received)
    self.received_quantity = (self.received_quantity || 0) + quantity_received
    self.status = 'partial' if received_quantity < quantity
    self.status = 'completed' if received_quantity >= quantity
    self.delivery_date = Date.current if status == 'completed'
    save!
  end
  
  def pending_quantity
    quantity - (received_quantity || 0)
  end
  
  def delivery_progress_percentage
    return 0 if quantity.zero?
    ((received_quantity || 0).to_f / quantity * 100).round(2)
  end
  
  private
  
  def generate_order_number
    prefix = "PO"
    date = Date.current.strftime('%Y%m%d')
    random = SecureRandom.hex(3).upcase
    self.order_number = "#{prefix}-#{date}-#{random}"
  end
  
  def calculate_totals
    self.subtotal = quantity * unit_price
    self.discount_amount ||= 0
    self.tax_amount ||= 0
    self.shipping_cost ||= 0
    self.total_amount = subtotal - discount_amount + tax_amount + shipping_cost
  end
  
  def check_delivery_completion
    if status_changed? && status == 'completed'
      create_inventory_entry
    end
  end
  
  def create_inventory_entry
    Inventory.create!(
      product: product,
      contact: contact,
      movement_type: 'IN',
      movement_reason: 'PURCHASE',
      quantity: quantity,
      unit_cost: unit_price,
      total_value: total_amount,
      document_type: 'purchase_order',
      document_number: order_number,
      purchase_order_id: id,
      user_id: user_id
    )
  end
end