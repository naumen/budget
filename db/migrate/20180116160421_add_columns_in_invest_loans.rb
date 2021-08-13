class AddColumnsInInvestLoans < ActiveRecord::Migration[5.1]
  def change
    add_column :invest_loans, :name, :string
    add_column :invest_loans, :document_id, :integer

    add_column :documents, :invest_loan_id, :integer

    remove_column :repayment_loans, :month
  end
end
