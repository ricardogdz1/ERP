class CreatePurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_orders do |t|
      t.string :order_number
      t.references :contact, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.date :order_date
      t.date :expected_delivery_date
      t.date :delivery_date
      t.string :status
      t.decimal :quantity
      t.money :unit_price
      t.decimal :discount_percent
      t.money :discount_amount
      t.money :subtotal
      t.money :tax_amount
      t.money :shipping_cost
      t.money :total_amount
      t.decimal :received_quantity
      t.string :payment_terms
      t.string :payment_method
      t.text :delivery_address
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
