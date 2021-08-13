class AddColumnInSaleChannel < ActiveRecord::Migration[5.1]
  def change
    add_column :sale_channels, :archived_date, :date
  end
end
