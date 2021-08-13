class AddDirectCostsToMetrik < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "Прямые расходы", code: "direct_costs"
  end
end
