class CreateMotivations < ActiveRecord::Migration[5.1]
  def change
    create_table :motivations do |t|
      t.integer :f_year
      t.integer :user_id
      t.string  :name
      t.integer :author
      t.integer :budget_id

      t.timestamps
    end
  end
end
