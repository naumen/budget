class CreateStaffItems < ActiveRecord::Migration[5.1]
  def change
    create_table :staff_items do |t|
      t.integer :position_id
      t.integer :division_id
      t.integer :user_staff_id
      t.integer :location_id
      t.float :koeff
    end
  end
end
