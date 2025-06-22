class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.string :movement_type
      t.decimal :quantity
      t.money :unit_cost
      t.money :total_value
      t.string :document_number
      t.string :document_type
      t.date :movement_date
      t.date :due_date
      t.text :notes
      t.string :batch_number
      t.date :expiration_date
      t.string :location
      t.integer :user_id
      t.boolean :is_confirmed

      t.timestamps
    end
  end
end
