class CreateUserStaffs < ActiveRecord::Migration[5.1]
  def change
    create_table :user_staffs do |t|
      t.integer :user_id
      t.integer :staff_item_id
      t.date :date_from
     t.date :date_closed
    end
  end
end
