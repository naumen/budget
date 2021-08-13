class CreateMonthMetrik < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "Общее кол-во ШЕ помесячно", code: "all_state_units_m"
  end
end
