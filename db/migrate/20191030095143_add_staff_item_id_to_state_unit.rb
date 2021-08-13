class AddStaffItemIdToStateUnit < ActiveRecord::Migration[5.1]
  def change
    add_column :state_units, :staff_item_id, :integer
  end
end
