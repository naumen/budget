# Model Zatrat
class Zatrat < ApplicationRecord
  validates :stat_zatr_id, presence: true
  validates :month, uniqueness: { scope: :stat_zatr_id,
    message: 'Нельзя дублировать значения по месяцам' }

  belongs_to :stat_zatr, class_name: 'StatZatr'
end
