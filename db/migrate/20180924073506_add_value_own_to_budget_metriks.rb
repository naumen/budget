class AddValueOwnToBudgetMetriks < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_metriks, :value_own, :decimal, precision: 15, scale: 2
  end
end
