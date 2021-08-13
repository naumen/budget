class CreateInvestLoans < ActiveRecord::Migration[5.1]
  def change
    create_table :invest_loans do |t|
      t.integer :use_budget_id
      t.integer :credit_budget_id
      t.string :currency
      t.float :summ
      t.float :interest_rate

      t.timestamps
    end
  end
end
