class CreateAccountsPayable < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts_payables do |t|
      t.references :contact, null: false, foreign_key: true
      t.string :description
      t.string :document_type
      t.string :document_number
      t.date :issue_date
      t.date :due_date
      t.date :payment_date
      t.money :original_amount
      t.money :discount_amount
      t.money :interest_amount
      t.money :paid_amount
      t.money :balance
      t.string :status
      t.string :payment_method
      t.string :category
      t.string :cost_center
      t.string :bank_account
      t.text :notes
      t.references :purchase_order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
