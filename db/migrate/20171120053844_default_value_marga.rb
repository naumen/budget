class DefaultValueMarga < ActiveRecord::Migration[5.1]
  def change
  	change_column_default :budgets, :plan_marga, 0
  end
end
