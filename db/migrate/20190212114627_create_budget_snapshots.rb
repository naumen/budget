class CreateBudgetSnapshots < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_snapshots do |t|
      t.string :budget_id
      t.text :json_content

      t.timestamps
    end
  end
end
