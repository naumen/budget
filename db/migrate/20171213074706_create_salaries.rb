class CreateSalaries < ActiveRecord::Migration[5.1]
  def change
    create_table :salaries do |t|
      t.integer :state_unit_id
      t.integer :month
      t.float :summ
      t.integer :f_year

      t.timestamps
    end
  end
end
