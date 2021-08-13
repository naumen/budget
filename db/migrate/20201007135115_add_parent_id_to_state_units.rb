class AddParentIdToStateUnits < ActiveRecord::Migration[5.1]
  def change
    add_column :state_units, :parent_id, :integer
  end
end
