class RemoveYearAndCurrencyInZatrats < ActiveRecord::Migration[5.1]
  def change
  	remove_column :zatrats, :year
  	remove_column :zatrats, :currency
  end
end
