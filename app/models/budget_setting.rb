# Model Budget
class BudgetSetting < ApplicationRecord
  belongs_to :setting_params, class_name: 'SettingParam', foreign_key: 'settings_params_id'
end
