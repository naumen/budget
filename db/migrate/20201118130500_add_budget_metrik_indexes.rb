class AddBudgetMetrikIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :budget_metriks, [:budget_id, :metrik_id, :archived_at]
  end
end
