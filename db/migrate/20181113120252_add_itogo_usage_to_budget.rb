class AddItogoUsageToBudget < ActiveRecord::Migration[5.1]
  def change
    add_column :budgets, :itogo_usage, :float, limit: 24, default: 0.0
  end
end
