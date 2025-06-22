class Inventory < ApplicationRecord
  # Validações
  validates :product_id, presence: true
  validates :movement_type, presence: true, inclusion: { in: %w[IN OUT ADJUSTMENT TRANSFER] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :movement_reason, presence: true
  
  # Relacionamentos
  belongs_to :product
  belongs_to :contact, optional: true
  belongs_to :user, optional: true
  
  # Callbacks
  after_create :update_product_stock
  
  # Scopes
  scope :entries, -> { where(movement_type: 'IN') }
  scope :exits, -> { where(movement_type: 'OUT') }
  scope :recent, -> { order(created_at: :desc) }
  
  private
  
  def update_product_stock
    case movement_type
    when 'IN'
      product.increment!(:current_stock, quantity)
    when 'OUT'
      product.decrement!(:current_stock, quantity)
    when 'ADJUSTMENT'
      product.update!(current_stock: quantity_after)
    end
  end
end