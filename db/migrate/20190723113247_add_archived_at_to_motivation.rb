class AddArchivedAtToMotivation < ActiveRecord::Migration[5.1]
  def change
    add_column :motivations, :archived_at, :datetime
  end
end
