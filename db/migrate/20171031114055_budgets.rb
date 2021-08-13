class Budgets < ActiveRecord::Migration[5.1]
  def change
  	create_table :budgets do |t|
      t.text :target
      t.integer :budget_id
      t.integer :f_year
      t.integer :budget_type_id
      t.integer :cfo_id
      t.integer :cfo_type_id
      t.integer :user_id
      t.integer :parent_id
      t.date :budget_create
      t.string :name
      t.string :state
      t.string :currency
      t.float :plan_marga
      t.float :plan_invest_marga
      t.float :nepredv
      t.float :all_zatrats_summ, :default => 0
      t.float :all_dohods_summ, :default => 0

      t.timestamps
    end
  end
end
