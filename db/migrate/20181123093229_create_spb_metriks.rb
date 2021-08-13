class CreateSpbMetriks < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "Кол-во штатных единиц в Питере", code: "location_state_unit_spb"
    Metrik.create name: "Помесячно по ШЕ Питер",          code: "location_state_unit_spb_m"
    Metrik.create name: "ФЗП по локациям Питер",          code: "fzp_by_location_spb"
  end
end
