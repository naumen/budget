# Model spr_location
class SprLocation < ApplicationRecord
  validates :name, presence: true

  has_many :state_units, class_name: 'StateUnit', foreign_key: 'location_id'
  has_many :budget_metriks, class_name: 'BudgetMetrik', foreign_key: 'location_id'

  def self.import
  end

end
