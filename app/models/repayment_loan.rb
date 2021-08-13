# Model RepaymentLoan
class RepaymentLoan < ApplicationRecord
  validates :fin_year, uniqueness: { scope: [:invest_loan_id],
    message: 'Нельзя дублировать значения по месяцам' }

  belongs_to :invest_loan, foreign_key: 'invest_loan_id'
end
