class AddFYearToSaleChannel < ActiveRecord::Migration[5.1]
  def change
    add_column :sale_channels, :f_year, :integer
  end
end
