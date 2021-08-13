# Model Budget
class SettingParam < ApplicationRecord
  has_many :budget_settings, class_name: 'BudgetSetting', foreign_key: 'settings_params_id'
  belongs_to :budget_type, class_name: 'BudgetType', foreign_key: 'budget_setting_type_id', optional: true
end
