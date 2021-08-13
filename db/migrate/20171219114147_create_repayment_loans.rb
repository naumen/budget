class CreateRepaymentLoans < ActiveRecord::Migration[5.1]
  def change
    create_table :repayment_loans do |t|
      t.integer :invest_loan_id
      t.integer :fin_year
      t.integer :month
      t.float :summ

      t.timestamps
    end
  end
end
