class Contact < ApplicationRecord
  # Validações
  validates :name, presence: true
  validates :document_number, uniqueness: { allow_blank: true }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  # Relacionamentos
  has_many :purchase_orders
  has_many :sales_orders
  has_many :accounts_payable
  has_many :accounts_receivable
  has_many :inventories
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :customers, -> { where(is_customer: true) }
  scope :suppliers, -> { where(is_supplier: true) }
  scope :transporters, -> { where(is_transporter: true) }
  
  # Métodos
  def type_list
    types = []
    types << "Cliente" if is_customer?
    types << "Fornecedor" if is_supplier?
    types << "Transportadora" if is_transporter?
    types << "Funcionário" if is_employee?
    types.join(", ")
  end
end