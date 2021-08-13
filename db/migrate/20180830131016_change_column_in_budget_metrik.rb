class ChangeColumnInBudgetMetrik < ActiveRecord::Migration[5.1]
  def change
    remove_column :budget_metriks, :location_id
    add_column :budget_metriks, :city, :string
  end
end
