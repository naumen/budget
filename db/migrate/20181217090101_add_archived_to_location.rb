class AddArchivedToLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :archived, :date
  end
end
