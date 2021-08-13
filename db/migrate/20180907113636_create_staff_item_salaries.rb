class CreateStaffItemSalaries < ActiveRecord::Migration[5.1]
  def change
    create_table :staff_item_salaries do |t|
      t.integer :f_month
      t.integer :f_year
      t.integer :salary
      t.integer :staff_item_id
      t.date :archive_date
      t.date :reserve_date
      t.integer :staff_request_id
      t.date :date_closed
    end
  end
end
