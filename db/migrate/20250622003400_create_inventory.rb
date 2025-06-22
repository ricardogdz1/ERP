class CreateInventory < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.references :product, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.string :movement_type
      t.string :movement_reason
      t.decimal :quantity
      t.decimal :quantity_before
      t.decimal :quantity_after
      t.money :unit_cost
      t.money :total_value
      t.money :average_cost
      t.string :batch_number
      t.string :serial_number
      t.date :expiration_date
      t.string :location
      t.string :warehouse
      t.string :document_type
      t.string :document_number
      t.date :document_date
      t.integer :purchase_order_id
      t.integer :sale_order_id
      t.text :notes
      t.integer :user_id

      t.timestamps
    end
  end
end
