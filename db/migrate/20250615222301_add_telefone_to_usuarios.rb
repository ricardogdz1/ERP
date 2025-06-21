class AddTelefoneToUsuarios < ActiveRecord::Migration[8.0]
  def change
    add_column :usuarios, :telefone, :string
  end
end
