# Model Naklad
class Naklad < ApplicationRecord
  belongs_to :budget
  belongs_to :normativ

  scope :actual, -> { where(archived_at: nil) }

  def self.nakladn_groups
    nakladn_groups = {}
    nakladn_groups['base']      = [nil, "Базовые"]
    nakladn_groups['by_weight'] = [nil, "По весу"]
    nakladn_groups['sale']   = [1,   "Продажи"]
    nakladn_groups['it']     = [2,   "ИТ"]
    nakladn_groups['hr']     = [3,   "HR"]
    nakladn_groups['office'] = [4,   "ОФИС"]
    nakladn_groups['growth'] = [5,   "Развитие"]
    nakladn_groups['new_services'] = [6,   "Новые сервисы"]
    nakladn_groups
  end

end
