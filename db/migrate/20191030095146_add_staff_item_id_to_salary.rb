class AddStaffItemIdToSalary < ActiveRecord::Migration[5.1]
  def change
    add_column :salaries, :staff_item_id, :integer
  end
end
