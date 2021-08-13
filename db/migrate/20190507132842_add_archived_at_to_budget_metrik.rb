class AddArchivedAtToBudgetMetrik < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_metriks, :archived_at, :datetime
  end
end
