class AddIsWithNdsToSale < ActiveRecord::Migration[5.1]
  def change
    add_column :sales, :is_with_nds, :boolean, default: false
  end
end
