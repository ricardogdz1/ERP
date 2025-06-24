class User < ApplicationRecord
  # Segurança para senha
  has_secure_password
  
  # Callbacks - Limpa dados ANTES de validar
  before_validation :sanitize_fields
  
  # Validações
  validates :name, presence: true, uniqueness: true, 
            format: { 
              with: /\A[a-zA-ZÀ-ÿ\s]+\z/, 
              message: "apenas letras e espaços são permitidos" 
            },
            length: { minimum: 3, maximum: 50 }
            
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, 
            allow_blank: true
            
  validates :role, presence: true, 
            inclusion: { in: %w[admin operator viewer], 
                        message: "deve ser admin, operator ou viewer" }
  
  # Relacionamentos
  has_many :purchase_orders
  has_many :sales_orders
  has_many :accounts_payable
  has_many :accounts_receivable
  
  # Scopes
  scope :active, -> { where(active: true) }
  
  # Métodos
  def admin?
    role == 'admin'
  end
  
  private
  
  # Limpa e formata campos antes de salvar
  def sanitize_fields
    # Remove espaços extras e caracteres invisíveis
    self.name = name.to_s.strip.squeeze(" ") if name.present?
    
    # Remove espaços do email
    self.email = email.to_s.strip.downcase if email.present?
    
    # Garante role em minúsculas
    self.role = role.to_s.strip.downcase if role.present?
    
    # Remove caracteres especiais perigosos
    self.name = name.gsub(/[—–―]/, "-") if name.present? # Substitui travessões por hífen
    self.name = name.gsub(/[^\p{L}\s\-']/, "") if name.present? # Remove caracteres não-letras
  end
end