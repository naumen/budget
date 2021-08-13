class AddCuratorIdToCfo < ActiveRecord::Migration[5.1]
  def change
    add_column :cfos, :curator_id, :integer
  end
end
