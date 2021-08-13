class ChangeColumnNameInBudget < ActiveRecord::Migration[5.1]
  def change
    remove_column :budgets, :parent_id
    rename_column :budgets, :budget_id, :parent_id
    add_column :budgets, :rgt, :integer, after: :parent_id
    add_column :budgets, :lft, :integer, after: :parent_id
  end
end
