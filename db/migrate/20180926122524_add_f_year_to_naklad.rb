class AddFYearToNaklad < ActiveRecord::Migration[5.1]
  def change
    add_column :naklads, :f_year, :integer
  end
end
