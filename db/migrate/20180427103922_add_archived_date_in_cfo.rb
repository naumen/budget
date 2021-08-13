class AddArchivedDateInCfo < ActiveRecord::Migration[5.1]
  def change
    add_column :cfos, :archived_date, :date
  end
end
