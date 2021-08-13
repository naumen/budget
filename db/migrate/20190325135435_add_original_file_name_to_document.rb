class AddOriginalFileNameToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :original_file_name, :string
  end
end
