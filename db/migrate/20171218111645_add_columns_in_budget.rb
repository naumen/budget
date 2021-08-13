class AddColumnsInBudget < ActiveRecord::Migration[5.1]
  def change
    add_column :budgets, :prev_budget_id, :integer
    add_column :budgets, :next_budget_id, :integer
  end
end
