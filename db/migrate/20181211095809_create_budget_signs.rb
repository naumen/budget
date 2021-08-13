class CreateBudgetSigns < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_signs do |t|
      t.integer :budget_id
      t.integer :user_id
      t.integer :s_order
      t.integer :attempt_num
      t.boolean :is_current_attempt
      t.integer :result
      t.timestamp :result_date
      t.text :comment
      t.timestamps
    end
  end
end
