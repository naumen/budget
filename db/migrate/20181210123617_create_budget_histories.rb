class CreateBudgetHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_histories do |t|
      t.integer :budget_id
      t.string  :state
      t.integer :user_id
      t.timestamps
    end
  end
end
