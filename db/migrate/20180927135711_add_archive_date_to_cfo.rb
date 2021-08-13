class AddArchiveDateToCfo < ActiveRecord::Migration[5.1]
  def change
    add_column :cfos, :archive_date, :date
  end
end
