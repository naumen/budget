# Model Metrik
class Metrik < ApplicationRecord
  has_many :budget_metrik, :class_name => 'BudgetMetrik'
  has_many :budget, through: :budget_metrik
end
