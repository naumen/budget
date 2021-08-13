class AddFYearToBudgetMetrik < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_metriks, :f_year, :integer
  end
end
