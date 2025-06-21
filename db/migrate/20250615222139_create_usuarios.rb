class CreateUsuarios < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios do |t|
      t.string :nome
      t.string :email
      t.integer :idade

      t.timestamps
    end
  end
end
