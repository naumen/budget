class AddFYearToSale < ActiveRecord::Migration[5.1]
  def change
    add_column :sales, :f_year, :integer
  end
end
