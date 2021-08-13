class AddDateClosedToStateUnit < ActiveRecord::Migration[5.1]
  def change
    add_column :state_units, :date_closed, :date
  end
end
