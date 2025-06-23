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
  
  # Scopes - NOMES ALTERADOS PARA EVITAR CONFLITO
  scope :stock_entries, -> { where(movement_type: 'IN') }      # Mudou de :entries
  scope :stock_exits, -> { where(movement_type: 'OUT') }       # Mudou de :exits
  scope :recent, -> { order(created_at: :desc) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_movement_type, ->(type) { where(movement_type: type) }
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  
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