class CreateSales < ActiveRecord::Migration[5.1]
  def change
    create_table :sales do |t|
      t.integer :budget_id
      t.integer :cfo_id
      t.integer :sale_channel_id
      t.integer :user_id
      t.integer :year
      t.integer :quarter
      t.float :summ, :default => 0
      t.string :currency
      t.string :name

      t.timestamps
    end
  end
end
