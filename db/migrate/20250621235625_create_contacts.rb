class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :company_name
      t.string :document_number
      t.string :email
      t.string :phone
      t.string :street
      t.string :number
      t.string :complement
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.boolean :is_customer
      t.boolean :is_supplier
      t.boolean :is_transporter
      t.boolean :is_employee
      t.boolean :is_service_provider
      t.boolean :is_representative
      t.boolean :is_partner
      t.boolean :active

      t.timestamps
    end
  end
end
