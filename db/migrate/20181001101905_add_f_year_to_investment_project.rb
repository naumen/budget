class AddFYearToInvestmentProject < ActiveRecord::Migration[5.1]
  def change
    add_column :investment_projects, :f_year, :integer
  end
end
