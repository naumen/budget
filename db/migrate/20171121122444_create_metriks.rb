class CreateMetriks < ActiveRecord::Migration[5.1]
  def change
    create_table :metriks do |t|
      t.string :name
      t.string :code
    end

    Metrik.create name: "Кол-во штатных единиц в Екатеринбурге", code: "location_state_unit_ekb"
    Metrik.create name: "ФЗП Бюджета", code:  "fzp"
    Metrik.create name: "Кол-во штатных единиц в Москве", code:   "location_state_unit_msk"
    Metrik.create name: "Кол-во штатных единиц в Твери", code:    "location_state_unit_twr"
    Metrik.create name: "Кол-во штатных единиц в Челябинске", code:   "location_state_unit_chel"
    Metrik.create name: "Кол-во штатных единиц в Киеве", code:    "location_state_unit_kiev"
    Metrik.create name: "Объем продаж", code:     "sales_total"
    Metrik.create name: "Кол-во вакантных штатных единиц", code:  "state_units_vakant"
    Metrik.create name: "Общее кол-во штатных единиц", code:  "all_state_units"
    Metrik.create name: "Поровну", code:  "equally"
    Metrik.create name: "По весу", code:  "by_weight"
    Metrik.create name: "Помесячно по ШЕ Екатеренбург", code:     "location_state_unit_ekb_m"
    Metrik.create name: "Помесячно по ШЕ Москва", code:   "location_state_unit_msk_m"
    Metrik.create name: "Помесячно по ШЕ Тверь", code:    "location_state_unit_twr_m"
    Metrik.create name: "Помесячно по ШЕ Челябинск", code:    "location_state_unit_chel_m"
    Metrik.create name: "Помесячно по ШЕ Киев", code:     "location_state_unit_kiev_m"
    Metrik.create name: "Помесячно по ШЕ Москва у клиента", code:     "location_state_unit_msk_m_client"
    Metrik.create name: "Кол-во штатных единиц в Москве у клиента", code:     "location_state_unit_msk_client"
    Metrik.create name: "Вакансии Екатеринбург", code:    "vacant_ekb"
    Metrik.create name: "Вакансии Москва", code:  "vacant_msk"
    Metrik.create name: "Руководитель Екатеринбург", code:    "chief_ekb"
    Metrik.create name: "Руководитель Москва", code:  "chief_msk"
    Metrik.create name: "Руководитель Тверь", code:   "chief_twr"
    Metrik.create name: "Руководитель Челябинск", code:   "chief_chel"
    Metrik.create name: "Специалист Екатеринбург", code:  "spec_ekb"
    Metrik.create name: "Специалист Москва", code:    "spec_msk"
    Metrik.create name: "Специалист Тверь", code:     "spec_twr"
    Metrik.create name: "Специалист Челябинск", code:     "spec_chel"
    Metrik.create name: "ФЗП по локациям", code:  "fzp_by_location"
    Metrik.create name: "Кол-во штатных единиц в Крыму", code:    "location_state_unit_krym"
    Metrik.create name: "Помесячно по ШЕ Крым", code:     "location_state_unit_krym_m"
    Metrik.create name: "ФЗП по локациям Члб", code:  "fzp_by_location_chel"
    Metrik.create name: "ФЗП по локациям Твр", code:  "fzp_by_location_twr"
    Metrik.create name: "ФЗП по локациям Сев", code:  "fzp_by_location_sev"
    Metrik.create name: "ФЗП по локациям Мск", code:  "fzp_by_location_msk"
    Metrik.create name: "Кол-во штатных единиц Удаленно", code:   "location_state_unit_external"
  end
end
