class AddArchivedAtToSprStatZatr < ActiveRecord::Migration[5.1]
  def change
    add_column :spr_stat_zatrs, :archived_at, :datetime
  end
end
