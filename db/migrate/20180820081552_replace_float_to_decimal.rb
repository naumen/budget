class ReplaceFloatToDecimal < ActiveRecord::Migration[5.1]
  def change
    change_column :sales, :summ, :decimal, precision: 15, scale: 2
    change_column :salaries, :summ, :decimal, precision: 15, scale: 2
    change_column :stat_zatrs, :all_summ, :decimal, precision: 15, scale: 2
    change_column :zatrats, :summ, :decimal, precision: 15, scale: 2
    change_column :budget_metriks, :value, :decimal, precision: 15, scale: 2
    change_column :invest_loans, :summ, :decimal, precision: 15, scale: 2
    change_column :investment_projects, :summ, :decimal, precision: 15, scale: 2
    change_column :naklads, :summ, :decimal, precision: 15, scale: 2
    change_column :naklads, :norm, :double
    change_column :naklads, :weight, :decimal, precision: 15, scale: 3
    change_column :normativ_params, :norm, :double
    change_column :normativ_params, :diff_in_rub, :decimal, precision: 15, scale: 2
    change_column :normativ_params, :diff_in_proc, :decimal, precision: 15, scale: 2
    change_column :repayment_loans, :summ, :decimal, precision: 15, scale: 2
  end
end
