class CreateTablesForSetting < ActiveRecord::Migration[5.1]
  def change
    create_table :setting_params do |t|
      t.string    :name
      t.integer   :setting_type
      t.integer   :budget_setting_type_id

      t.timestamps
    end

    SettingParam.create( name: 'Продажи',        setting_type: 1 )
    SettingParam.create( name: 'Нормативы',      setting_type: 1 )
    SettingParam.create( name: 'Инвест проекты', setting_type: 1 )
    SettingParam.create( name: 'Инвест займ',    setting_type: 1 )
    SettingParam.create( name: 'Статьи затрат',  setting_type: 2 )
    SettingParam.create( name: 'Накладные',      setting_type: 2 )
    SettingParam.create( name: 'Инвест проекты', setting_type: 2 )
    SettingParam.create( name: 'Инвест займ',    setting_type: 2 )
    SettingParam.create( name: 'ФЗП',            setting_type: 2 )
    SettingParam.create( name: 'Сводный',                    setting_type: 3, budget_setting_type_id: 1 )
    SettingParam.create( name: 'Обеспечивающий',             setting_type: 3, budget_setting_type_id: 2 )
    SettingParam.create( name: 'Зарплата подразделений',     setting_type: 3, budget_setting_type_id: 3 )
    SettingParam.create( name: 'Инвестиционные компании',    setting_type: 3, budget_setting_type_id: 4 )
    SettingParam.create( name: 'Инвестиционные направления', setting_type: 3, budget_setting_type_id: 5 )
    SettingParam.create( name: 'Маркетинг',                  setting_type: 3, budget_setting_type_id: 6 )
    SettingParam.create( name: 'Сводные компании',           setting_type: 3, budget_setting_type_id: 7 )
    SettingParam.create( name: 'Сводный БН',                 setting_type: 3, budget_setting_type_id: 8 )
    SettingParam.create( name: 'Сводный СН',                 setting_type: 3, budget_setting_type_id: 9 )
    SettingParam.create( name: 'Сводный УпБН',               setting_type: 3, budget_setting_type_id: 10 )



    create_table :budget_settings do |t|
      t.integer   :budget_setting_type_id
      t.integer   :settings_params_id

      t.timestamps
    end
  end
end
