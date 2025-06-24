class SalesOrder < ApplicationRecord
  # Constantes
  STATUSES = %w[draft pending confirmed processing shipped delivered cancelled].freeze
  PAYMENT_METHODS = %w[cash credit_card debit_card bank_transfer pix].freeze
  
  # Associações
  belongs_to :contact # cliente
  belongs_to :product
  belongs_to :user
  
  # Validações
  validates :order_number, presence: true, uniqueness: true
  validates :order_date, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  
  # Callbacks
  before_validation :generate_order_number, on: :create
  before_save :calculate_totals
  before_save :check_product_availability
  after_update :process_inventory_movement
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :active, -> { where.not(status: ['cancelled', 'delivered']) }
  scope :delivered, -> { where(status: 'delivered') }
  scope :by_customer, ->(contact_id) { where(contact_id: contact_id) }
  scope :today, -> { where(order_date: Date.current) }
  scope :this_month, -> { where(order_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  
  # Métodos públicos
  def customer
    contact
  end
  
  def confirm!
    transaction do
      update!(status: 'confirmed')
      reserve_stock
    end
  end
  
  def cancel!
    return false if %w[delivered shipped].include?(status)
    transaction do
      release_stock if %w[confirmed processing].include?(status)
      update!(status: 'cancelled')
    end
  end
  
  def ship!
    update!(status: 'shipped', delivery_date: Date.current)
  end
  
  def deliver!
    transaction do
      update!(status: 'delivered', delivery_date: Date.current, delivered_quantity: quantity)
      create_inventory_movement
    end
  end
  
  def can_cancel?
    !%w[delivered shipped].include?(status)
  end
  
  def profit
    (unit_price - product.cost_price) * quantity
  end
  
  def profit_margin_percentage
    return 0 if unit_price.zero?
    ((unit_price - product.cost_price) / unit_price * 100).round(2)
  end
  
  private
  
  def generate_order_number
    prefix = "SO"
    date = Date.current.strftime('%Y%m%d')
    sequence = SalesOrder.where('created_at >= ?', Date.current.beginning_of_day).count + 1
    self.order_number = "#{prefix}-#{date}-#{sequence.to_s.rjust(4, '0')}"
  end
  
  def calculate_totals
    self.subtotal = quantity * unit_price
    
    # Aplicar desconto percentual
    if discount_percent.present? && discount_percent > 0
      self.discount_amount = subtotal * (discount_percent / 100.0)
    end
    
    self.discount_amount ||= 0
    self.tax_amount ||= subtotal * 0.18 # 18% de imposto padrão
    self.shipping_cost ||= 0
    self.total_amount = subtotal - discount_amount + tax_amount + shipping_cost
  end
  
  def check_product_availability
    if quantity_changed? && product.requires_stock_control?
      if quantity > product.current_stock
        errors.add(:quantity, "insuficiente em estoque (disponível: #{product.current_stock})")
        throw :abort
      end
    end
  end
  
  def reserve_stock
    # Implementar lógica de reserva se necessário
  end
  
  def release_stock
    # Implementar lógica de liberação se necessário
  end
  
  def process_inventory_movement
    if status_previously_changed? && status == 'delivered'
      create_inventory_movement
    end
  end
  
  def create_inventory_movement
    Inventory.create!(
      product: product,
      contact: contact,
      movement_type: 'OUT',
      movement_reason: 'SALE',
      quantity: quantity,
      unit_cost: product.cost_price,
      total_value: total_amount,
      document_type: 'sales_order',
      document_number: order_number,
      sale_order_id: id,
      user_id: user_id
    )
  end
end