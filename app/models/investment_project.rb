# Model InvestmentProject
class InvestmentProject < ApplicationRecord
  validates :name, :from_budget_id, :to_budget_id, :summ, presence: true

  belongs_to :from_budget, class_name: 'Budget', foreign_key: 'from_budget_id'
  belongs_to :to_budget, class_name: 'Budget', foreign_key: 'to_budget_id'
  belongs_to :document, foreign_key: 'document_id', optional: true
end
