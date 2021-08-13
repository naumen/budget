# Model NormativTypes
class NormativType < ApplicationRecord
  validates :name, presence: true
end