class RemoveCfoYearCurrencyColumn < ActiveRecord::Migration[5.1]
  def change
  	remove_column :sales, :cfo_id
  	remove_column :sales, :year
  	remove_column :sales, :currency
  end
end
