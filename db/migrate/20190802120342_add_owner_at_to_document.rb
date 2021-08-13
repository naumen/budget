class AddOwnerAtToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :owner_id, :integer
    add_column :documents, :owner_type, :string
  end
end
