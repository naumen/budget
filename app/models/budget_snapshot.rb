class BudgetSnapshot < ApplicationRecord

  def self.make_snapshot(budget)
    bs = BudgetSnapshot.new
    bs.budget_id    = budget.id
    bs.json_content = budget.as_json
    bs.save
    bs
  end

  def restore_snapshot
    JSON.parse(self.json_content)
  end

end
