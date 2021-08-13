class CreateKdrMetriks < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "Кол-во штатных единиц в Краснодаре", code: "location_state_unit_kdr"
    Metrik.create name: "Помесячно по ШЕ Краснодар",          code: "location_state_unit_kdr_m"
    Metrik.create name: "ФЗП по локациям Краснодар",          code: "fzp_by_location_kdr"
  end
end
