class AccountReceivable < ApplicationRecord
  # Constantes
  STATUSES = %w[pending partial received overdue cancelled].freeze
  DOCUMENT_TYPES = %w[invoice receipt contract service_order other].freeze
  PAYMENT_METHODS = %w[cash bank_transfer credit_card debit_card pix check].freeze
  CATEGORIES = %w[
    product_sales service_revenue rent_income interest_income
    commission other_income
  ].freeze
  
  # Associações
  belongs_to :contact
  belongs_to :user
  belongs_to :sales_order, optional: true
  
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
  after_update :check_payment_notification
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :received, -> { where(status: 'received') }
  scope :overdue, -> { where('due_date < ? AND status NOT IN (?)', Date.current, ['received', 'cancelled']) }
  scope :due_today, -> { where(due_date: Date.current, status: 'pending') }
  scope :due_this_week, -> { where(due_date: Date.current..Date.current.end_of_week) }
  scope :by_customer, ->(contact_id) { where(contact_id: contact_id) }
  scope :by_category, ->(category) { where(category: category) }
  scope :current_month, -> { where(due_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  
  # Métodos públicos
  def customer
    contact
  end
  
  def receive!(amount, payment_date = Date.current, payment_method = nil)
    transaction do
      self.received_amount = (received_amount || 0) + amount
      self.payment_date = payment_date
      self.payment_method = payment_method if payment_method.present?
      
      if received_amount >= original_amount
        self.status = 'received'
      else
        self.status = 'partial'
      end
      
      save!
      create_receipt_record(amount, payment_date)
    end
  end
  
  def cancel!(reason = nil)
    return false if status == 'received'
    update!(status: 'cancelled', notes: [notes, "Cancelado: #{reason}"].compact.join("\n"))
  end
  
  def send_reminder!
    # Implementar envio de lembrete
    update!(last_reminder_sent_at: Time.current)
  end
  
  def days_until_due
    (due_date - Date.current).to_i
  end
  
  def days_overdue
    return 0 unless overdue?
    (Date.current - due_date).to_i
  end
  
  def overdue?
    due_date < Date.current && !%w[received cancelled].include?(status)
  end
  
  def percentage_received
    return 0 if original_amount.zero?
    ((received_amount || 0) / original_amount * 100).round(2)
  end
  
  def remaining_amount
    original_amount - (received_amount || 0) + (interest_amount || 0) - (discount_amount || 0)
  end
  
  def apply_discount!(discount_percentage)
    return false if status == 'received'
    self.discount_amount = original_amount * (discount_percentage / 100.0)
    save!
  end
  
  def apply_late_fee!(fee_percentage = 2.0)
    return unless overdue?
    self.interest_amount = original_amount * (fee_percentage / 100.0)
    save!
  end
  
  def projected_revenue(start_date, end_date)
    if due_date.between?(start_date, end_date) && status != 'cancelled'
      remaining_amount
    else
      0
    end
  end
  
  private
  
  def set_initial_values
    self.status ||= 'pending'
    self.received_amount ||= 0
    self.discount_amount ||= 0
    self.interest_amount ||= 0
    self.issue_date ||= Date.current
  end
  
  def calculate_balance
    self.balance = remaining_amount
  end
  
  def update_status
    if status != 'cancelled'
      if received_amount >= original_amount
        self.status = 'received'
      elsif overdue?
        self.status = 'overdue'
      elsif received_amount > 0
        self.status = 'partial'
      else
        self.status = 'pending'
      end
    end
  end
  
  def check_payment_notification
    if status_previously_changed? && status == 'received'
      # Notificar conclusão do pagamento
      # NotificationService.payment_received(self)
    end
  end
  
  def create_receipt_record(amount, payment_date)
    # Criar registro de recebimento se tiver tabela receipts
    # Receipt.create!(
    #   account_receivable: self,
    #   amount: amount,
    #   payment_date: payment_date,
    #   user: user
    # )
  end
  
  # Método de classe para análise
  def self.cash_flow_projection(days = 30)
    end_date = Date.current + days.days
    
    {
      total: where(due_date: Date.current..end_date, status: ['pending', 'partial']).sum(:balance),
      by_week: where(due_date: Date.current..end_date, status: ['pending', 'partial'])
                 .group_by_week(:due_date).sum(:balance),
      overdue: overdue.sum(:balance)
    }
  end
end