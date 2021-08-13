class AddNormativInTwoTable < ActiveRecord::Migration[5.1]
  def change
    create_table :normativ_cores do |t|
      t.integer :fin_year
      t.integer :parent_id

      t.timestamps
    end

    create_table :normativ_params do |t|
      t.integer :normativ_core_id
      t.string :name
      t.float :norm
      t.text :description
      t.integer :budget_id
      t.integer :metriks_id
      t.string :comment
      t.integer :normativ_type_id
      t.float :diff_in_rub
      t.float :diff_in_proc

      t.datetime :opened_at
      t.datetime :closed_at
      t.timestamps
    end
  end
end
