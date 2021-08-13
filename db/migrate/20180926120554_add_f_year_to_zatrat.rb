class AddFYearToZatrat < ActiveRecord::Migration[5.1]
  def change
    add_column :zatrats, :f_year, :integer
  end
end
