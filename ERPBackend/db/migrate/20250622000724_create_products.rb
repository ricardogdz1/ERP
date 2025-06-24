class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :sku
      t.string :barcode
      t.string :category
      t.string :unit_of_measure
      t.money :cost_price
      t.money :sale_price
      t.integer :minimum_stock
      t.integer :current_stock
      t.integer :maximum_stock
      t.decimal :net_weight
      t.decimal :gross_weight
      t.string :dimensions
      t.string :brand
      t.string :supplier_code
      t.string :location
      t.date :expiration_date
      t.boolean :is_active
      t.boolean :is_service
      t.boolean :requires_stock_control

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
