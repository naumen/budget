# Model InvestLoan
class InvestLoan < ApplicationRecord
  validates :name, :summ, :use_budget_id, :credit_budget_id, presence: true

  belongs_to :use_budget, class_name: 'Budget', foreign_key: 'use_budget_id'
  belongs_to :credit_budget, class_name: 'Budget', foreign_key: 'credit_budget_id'

  has_many :repayment_loans, class_name: 'RepaymentLoan', foreign_key: 'invest_loan_id'
  belongs_to :document, foreign_key: 'document_id', optional: true

  def term
    max = 0
    min = 10000
    if !self.repayment_loans.empty?
      self.repayment_loans.each do |repayment_loan|
        max = repayment_loan.fin_year if repayment_loan.fin_year > max
        min = repayment_loan.fin_year if repayment_loan.fin_year < min

      end
      return max - self.use_budget.f_year
    end
  end
end
