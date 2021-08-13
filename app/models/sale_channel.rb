# Model SaleChannel
class SaleChannel < ApplicationRecord
  validates :name, presence: true
  scope :sorted, -> { order(:archived_date) }
  scope :only_actual, -> { where(archived_date: nil) }
end
