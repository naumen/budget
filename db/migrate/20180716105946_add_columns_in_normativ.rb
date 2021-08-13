class AddColumnsInNormativ < ActiveRecord::Migration[5.1]
  def change
    add_column :normativs, :comment, :string
    add_column :normativs, :normativ_type_id, :integer
    add_column :normativs, :normativ_in_last_year, :integer
    add_column :normativs, :diff_in_rub, :float
    add_column :normativs, :diff_in_proc, :float
    add_column :normativs, :f_year, :integer
  end
end
