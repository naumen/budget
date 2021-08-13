class CreateNormativs < ActiveRecord::Migration[5.1]
  def change
    create_table :normativs do |t|
      t.string :name
      t.float :norm
      t.text :description
      t.integer :budget_id
      t.integer :metrik_id

      t.timestamps
    end
  end
end
