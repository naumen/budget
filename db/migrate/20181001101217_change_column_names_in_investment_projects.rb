class ChangeColumnNamesInInvestmentProjects < ActiveRecord::Migration[5.1]
  def change
    rename_column :investment_projects, :use_budget_id,     :from_budget_id
    rename_column :investment_projects, :filling_budget_id, :to_budget_id
  end
end
