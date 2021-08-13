class AddBudgetSnapshotIdToRequestChange < ActiveRecord::Migration[5.1]
  def change
    add_column :request_changes, :budget_snapshot_id, :integer
  end
end
