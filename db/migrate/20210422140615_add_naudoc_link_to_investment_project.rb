class AddNaudocLinkToInvestmentProject < ActiveRecord::Migration[5.1]
  def change
    add_column :investment_projects, :naudoc_link, :string
  end
end
