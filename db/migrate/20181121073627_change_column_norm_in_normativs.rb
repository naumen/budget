class ChangeColumnNormInNormativs < ActiveRecord::Migration[5.1]
  def change
    change_column :normativs, :norm, :decimal, precision: 13, scale: 4
  end
end
