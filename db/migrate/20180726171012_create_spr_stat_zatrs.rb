class CreateSprStatZatrs < ActiveRecord::Migration[5.1]
  def change
    create_table :spr_stat_zatrs do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_column :stat_zatrs, :spr_stat_zatrs_id, :integer
  end
end
