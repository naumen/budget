class CreateNaklads < ActiveRecord::Migration[5.1]
  def change
    create_table :naklads do |t|
      t.integer :budget_id
      t.float :norm
      t.integer :normativ_id
      t.float :summ
      t.float :weight
      t.string :naklad_method
      t.integer :sales_type_id

      t.timestamps
    end
  end
end
