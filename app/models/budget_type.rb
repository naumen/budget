# Model BudgetType
class BudgetType < ApplicationRecord

  validates :name, presence: true

  has_many :budget, foreign_key: "budget_type_id"
  has_many :budget_setting, foreign_key: "budget_setting_type_id"
end
