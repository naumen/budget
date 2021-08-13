class AddBudgetInfoToBudget < ActiveRecord::Migration[5.1]
  def change
    add_column :budgets, :budget_info, :string
  end
end
