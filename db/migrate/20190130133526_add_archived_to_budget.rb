class AddArchivedToBudget < ActiveRecord::Migration[5.1]
  def change
    add_column :budgets, :archived, :date
  end
end
