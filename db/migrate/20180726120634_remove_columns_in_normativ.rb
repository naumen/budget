class RemoveColumnsInNormativ < ActiveRecord::Migration[5.1]
  def change
    remove_column :normativs, :normativ_in_last_year

    add_column :normativs, :normativ_in_prev_year_id, :integer
  end
end
