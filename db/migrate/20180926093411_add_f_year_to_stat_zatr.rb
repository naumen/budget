class AddFYearToStatZatr < ActiveRecord::Migration[5.1]
  def change
    add_column :stat_zatrs, :f_year, :integer
  end
end
