class AddSostavZatratToNormativs < ActiveRecord::Migration[5.1]
  def change
    add_column :normativs, :sostav_zatrat, :text
  end
end
