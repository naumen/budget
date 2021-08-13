class AddItogoInToBudget < ActiveRecord::Migration[5.1]
  def change
    add_column :budgets, :itogo_in, :float
  end
end
