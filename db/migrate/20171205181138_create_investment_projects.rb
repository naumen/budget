class CreateInvestmentProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :investment_projects do |t|
      t.string  :name
      t.integer :use_budget_id
      t.integer :filling_budget_id
      t.string  :currency
      t.float :summ
      t.integer :document_id

      t.timestamps
    end
  end
end
