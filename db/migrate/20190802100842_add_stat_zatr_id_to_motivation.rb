class AddStatZatrIdToMotivation < ActiveRecord::Migration[5.1]
  def change
    add_column :motivations, :stat_zatr_id, :integer
  end
end
