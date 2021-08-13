class BudgetHistory < ApplicationRecord

  belongs_to :budget
  belongs_to :user

  def self.log(budget_id, user_id, state)
      bh = BudgetHistory.new
      bh.budget_id = budget_id
      bh.user_id = user_id
      bh.state   = state
      bh.save
  end
end
