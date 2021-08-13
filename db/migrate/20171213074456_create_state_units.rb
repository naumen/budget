class CreateStateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :state_units do |t|
      t.integer :budget_id
      t.integer :user_id
      t.integer :f_year
      t.float :rate
      t.string :position
      t.string :division

      t.timestamps
    end
  end
end
