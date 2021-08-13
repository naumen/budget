class CreateSnapshots < ActiveRecord::Migration[5.1]
  def change
    create_table :snapshots do |t|
      t.string :database_name
      t.string :current_folder
      t.boolean :active
      t.float :filling_money
      t.float :def_prof_money

      t.timestamps
    end
  end
end
