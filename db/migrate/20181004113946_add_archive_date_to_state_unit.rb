class AddArchiveDateToStateUnit < ActiveRecord::Migration[5.1]
  def change
    add_column :state_units, :archive_date, :date
  end
end
