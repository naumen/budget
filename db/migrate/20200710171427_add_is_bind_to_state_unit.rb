class AddIsBindToStateUnit < ActiveRecord::Migration[5.1]
  def change
    add_column :state_units, :is_bind, :boolean, default: false
  end
end
