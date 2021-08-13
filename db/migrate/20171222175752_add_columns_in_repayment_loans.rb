class AddColumnsInRepaymentLoans < ActiveRecord::Migration[5.1]
  def change
    add_column :repayment_loans, :from_budget_id, :integer
    add_column :repayment_loans, :to_budget_id, :integer
  end
end
