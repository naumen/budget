class AddColumnInCfo < ActiveRecord::Migration[5.1]
  def change
    add_column :cfos, :manager_id, :integer
  end
end
