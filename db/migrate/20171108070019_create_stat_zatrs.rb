class CreateStatZatrs < ActiveRecord::Migration[5.1]
  def change
    create_table :stat_zatrs do |t|
      t.integer :spr_stat_zatr_id
      t.integer :budget_id
      t.string :name
      t.float :all_summ, :default => 0

      t.timestamps
    end
  end
end
