class Product < ApplicationRecord
  # Validações
  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :unit_of_measure, presence: true
  validates :sale_price, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_price, numericality: { greater_than_or_equal_to: 0 }
  
  # Relacionamentos
  has_many :inventories
  has_many :purchase_order_items, class_name: 'PurchaseOrder'
  has_many :sales_order_items, class_name: 'SalesOrder'
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :services, -> { where(is_service: true) }
  scope :products, -> { where(is_service: false) }
  scope :low_stock, -> { where('current_stock <= minimum_stock') }
  
  # Callbacks
  before_validation :set_defaults
  
  # Métodos
  def in_stock?
    return true if is_service?
    current_stock > 0
  end
  
  def stock_status
    return "N/A" if is_service?
    return "Crítico" if current_stock <= 0
    return "Baixo" if current_stock <= minimum_stock
    "Normal"
  end
  
  def profit_margin
    return 0 if cost_price.zero?
    ((sale_price - cost_price) / cost_price * 100).round(2)
  end
  
  private
  
  def set_defaults
    self.current_stock ||= 0
    self.minimum_stock ||= 0
    self.is_active = true if is_active.nil?
  end
end