# Model CFO
class Cfo < ApplicationRecord
  has_many :budget, foreign_key: 'cfo_id'

  scope :sorted, -> { order(:name) }

  def self.import
  end
end
