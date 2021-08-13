class CreateBudgetParams < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_params do |t|
      t.string :budgets_report_access

      t.timestamps
    end

    b = BudgetParam.new
    b.budgets_report_access = ''
    b.save
  end
end
