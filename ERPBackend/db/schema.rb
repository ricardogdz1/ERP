# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_22_011644) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts_payables", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.string "description"
    t.string "document_type"
    t.string "document_number"
    t.date "issue_date"
    t.date "due_date"
    t.date "payment_date"
    t.money "original_amount", scale: 2
    t.money "discount_amount", scale: 2
    t.money "interest_amount", scale: 2
    t.money "paid_amount", scale: 2
    t.money "balance", scale: 2
    t.string "status"
    t.string "payment_method"
    t.string "category"
    t.string "cost_center"
    t.string "bank_account"
    t.text "notes"
    t.bigint "purchase_order_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_accounts_payables_on_contact_id"
    t.index ["purchase_order_id"], name: "index_accounts_payables_on_purchase_order_id"
    t.index ["user_id"], name: "index_accounts_payables_on_user_id"
  end

  create_table "accounts_receivables", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.string "description"
    t.string "document_type"
    t.string "document_number"
    t.date "issue_date"
    t.date "due_date"
    t.date "payment_date"
    t.money "original_amount", scale: 2
    t.money "discount_amount", scale: 2
    t.money "interest_amount", scale: 2
    t.money "received_amount", scale: 2
    t.money "balance", scale: 2
    t.string "status"
    t.string "payment_method"
    t.string "category"
    t.string "revenue_center"
    t.string "bank_account"
    t.text "notes"
    t.bigint "sales_order_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_accounts_receivables_on_contact_id"
    t.index ["sales_order_id"], name: "index_accounts_receivables_on_sales_order_id"
    t.index ["user_id"], name: "index_accounts_receivables_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.string "document_number"
    t.string "email"
    t.string "phone"
    t.string "street"
    t.string "number"
    t.string "complement"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.boolean "is_customer"
    t.boolean "is_supplier"
    t.boolean "is_transporter"
    t.boolean "is_employee"
    t.boolean "is_service_provider"
    t.boolean "is_representative"
    t.boolean "is_partner"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "contact_id", null: false
    t.string "movement_type"
    t.string "movement_reason"
    t.decimal "quantity"
    t.decimal "quantity_before"
    t.decimal "quantity_after"
    t.money "unit_cost", scale: 2
    t.money "total_value", scale: 2
    t.money "average_cost", scale: 2
    t.string "batch_number"
    t.string "serial_number"
    t.date "expiration_date"
    t.string "location"
    t.string "warehouse"
    t.string "document_type"
    t.string "document_number"
    t.date "document_date"
    t.integer "purchase_order_id"
    t.integer "sale_order_id"
    t.text "notes"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_inventories_on_contact_id"
    t.index ["product_id"], name: "index_inventories_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "sku"
    t.string "barcode"
    t.string "category"
    t.string "unit_of_measure"
    t.money "cost_price", scale: 2
    t.money "sale_price", scale: 2
    t.integer "minimum_stock"
    t.integer "current_stock"
    t.integer "maximum_stock"
    t.decimal "net_weight"
    t.decimal "gross_weight"
    t.string "dimensions"
    t.string "brand"
    t.string "supplier_code"
    t.string "location"
    t.date "expiration_date"
    t.boolean "is_active"
    t.boolean "is_service"
    t.boolean "requires_stock_control"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string "order_number"
    t.bigint "contact_id", null: false
    t.bigint "product_id", null: false
    t.date "order_date"
    t.date "expected_delivery_date"
    t.date "delivery_date"
    t.string "status"
    t.decimal "quantity"
    t.money "unit_price", scale: 2
    t.decimal "discount_percent"
    t.money "discount_amount", scale: 2
    t.money "subtotal", scale: 2
    t.money "tax_amount", scale: 2
    t.money "shipping_cost", scale: 2
    t.money "total_amount", scale: 2
    t.decimal "received_quantity"
    t.string "payment_terms"
    t.string "payment_method"
    t.text "delivery_address"
    t.text "notes"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_purchase_orders_on_contact_id"
    t.index ["product_id"], name: "index_purchase_orders_on_product_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "sales_orders", force: :cascade do |t|
    t.string "order_number"
    t.bigint "contact_id", null: false
    t.bigint "product_id", null: false
    t.date "order_date"
    t.date "expected_delivery_date"
    t.date "delivery_date"
    t.string "status"
    t.decimal "quantity"
    t.money "unit_price", scale: 2
    t.decimal "discount_percent"
    t.money "discount_amount", scale: 2
    t.money "subtotal", scale: 2
    t.money "tax_amount", scale: 2
    t.money "shipping_cost", scale: 2
    t.money "total_amount", scale: 2
    t.decimal "delivered_quantity"
    t.string "payment_terms"
    t.string "payment_method"
    t.text "delivery_address"
    t.text "notes"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_sales_orders_on_contact_id"
    t.index ["product_id"], name: "index_sales_orders_on_product_id"
    t.index ["user_id"], name: "index_sales_orders_on_user_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "contact_id", null: false
    t.string "movement_type"
    t.decimal "quantity"
    t.money "unit_cost", scale: 2
    t.money "total_value", scale: 2
    t.string "document_number"
    t.string "document_type"
    t.date "movement_date"
    t.date "due_date"
    t.text "notes"
    t.string "batch_number"
    t.date "expiration_date"
    t.string "location"
    t.integer "user_id"
    t.boolean "is_confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_stock_movements_on_contact_id"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts_payables", "contacts"
  add_foreign_key "accounts_payables", "purchase_orders"
  add_foreign_key "accounts_payables", "users"
  add_foreign_key "accounts_receivables", "contacts"
  add_foreign_key "accounts_receivables", "sales_orders"
  add_foreign_key "accounts_receivables", "users"
  add_foreign_key "inventories", "contacts"
  add_foreign_key "inventories", "products"
  add_foreign_key "purchase_orders", "contacts"
  add_foreign_key "purchase_orders", "products"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "sales_orders", "contacts"
  add_foreign_key "sales_orders", "products"
  add_foreign_key "sales_orders", "users"
  add_foreign_key "stock_movements", "contacts"
  add_foreign_key "stock_movements", "products"
end
