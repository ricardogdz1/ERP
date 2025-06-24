class AccountPayable < ApplicationRecord
  # Constantes
  STATUSES = %w[pending partial paid overdue cancelled].freeze
  DOCUMENT_TYPES = %w[invoice receipt contract other].freeze
  PAYMENT_METHODS = %w[cash bank_transfer credit_card debit_card pix check].freeze
  CATEGORIES = %w[
    suppliers inventory rent utilities salaries taxes
    maintenance marketing equipment other
  ].freeze
  
  # Associações
  belongs_to :contact
  belongs_to :user
  belongs_to :purchase_order, optional: true
  
  # Validações
  validates :description, presence: true
  validates :due_date, presence: true
  validates :original_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :document_type, inclusion: { in: DOCUMENT_TYPES }, allow_blank: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
  
  # Callbacks
  before_validation :set_initial_values, on: :create
  before_save :calculate_balance
  after_save :update_status
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :overdue, -> { where('due_date < ? AND status != ?', Date.current, 'paid') }
  scope :due_today, -> { where(due_date: Date.current, status: 'pending') }
  scope :due_this_week, -> { where(due_date: Date.current..Date.current.end_of_week) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_supplier, ->(contact_id) { where(contact_id: contact_id) }
  scope :current_month, -> { where(due_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  
  # Métodos públicos
  def supplier
    contact
  end
  
  def pay!(amount, payment_date = Date.current, payment_method = nil)
    transaction do
      self.paid_amount = (paid_amount || 0) + amount
      self.payment_date = payment_date
      self.payment_method = payment_method if payment_method.present?
      
      if paid_amount >= original_amount
        self.status = 'paid'
      else
        self.status = 'partial'
      end
      
      save!
      create_payment_record(amount, payment_date)
    end
  end
  
  def cancel!(reason = nil)
    return false if status == 'paid'
    update!(status: 'cancelled', notes: [notes, "Cancelado: #{reason}"].compact.join("\n"))
  end
  
  def days_until_due
    (due_date - Date.current).to_i
  end
  
  def days_overdue
    return 0 unless overdue?
    (Date.current - due_date).to_i
  end
  
  def overdue?
    due_date < Date.current && status != 'paid'
  end
  
  def percentage_paid
    return 0 if original_amount.zero?
    ((paid_amount || 0) / original_amount * 100).round(2)
  end
  
  def remaining_amount
    original_amount - (paid_amount || 0) + (interest_amount || 0) - (discount_amount || 0)
  end
  
  def apply_late_interest!(interest_rate = 0.02)
    return unless overdue?
    days = days_overdue
    self.interest_amount = original_amount * interest_rate * days / 30
    save!
  end
  
  private
  
  def set_initial_values
    self.status ||= 'pending'
    self.paid_amount ||= 0
    self.discount_amount ||= 0
    self.interest_amount ||= 0
    self.issue_date ||= Date.current
  end
  
  def calculate_balance
    self.balance = remaining_amount
  end
  
  def update_status
    if status != 'cancelled'
      if paid_amount >= original_amount
        self.status = 'paid'
      elsif overdue?
        self.status = 'overdue'
      elsif paid_amount > 0
        self.status = 'partial'
      else
        self.status = 'pending'
      end
    end
  end
  
  def create_payment_record(amount, payment_date)
    # Aqui você pode criar um registro de pagamento se tiver uma tabela payments
    # Payment.create!(
    #   account_payable: self,
    #   amount: amount,
    #   payment_date: payment_date,
    #   user: user
    # )
  end
end