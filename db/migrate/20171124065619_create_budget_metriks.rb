class CreateBudgetMetriks < ActiveRecord::Migration[5.1]
  def change
    create_table :budget_metriks do |t|
      t.integer :budget_id
      t.integer :metrik_id
      t.float   :value
      

      t.timestamps
    end
  end
end
