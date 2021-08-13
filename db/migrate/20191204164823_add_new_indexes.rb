class AddNewIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :users_roles, [:user_id, :budget_id]
    add_index :users_roles, [:user_id, :role]
    add_index :budgets, :parent_id
    add_index :budgets, :lft
    add_index :budgets, :rgt
  end
end
