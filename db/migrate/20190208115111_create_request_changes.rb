class CreateRequestChanges < ActiveRecord::Migration[5.1]
  def change
    create_table :request_changes do |t|
      t.string :name
      t.integer :author_id
      t.integer :budget_id

      t.timestamps
    end
  end
end
