class CreateZatrats < ActiveRecord::Migration[5.1]
  def change
    create_table :zatrats do |t|
      t.integer :stat_zatr_id
      t.integer :year
      t.integer :month
      t.float :summ
      t.string :currency
      t.boolean :nal_beznal

      t.timestamps
    end
  end
end
