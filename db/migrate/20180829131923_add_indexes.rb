class AddIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :state_units, :budget_id
    add_index :salaries, :state_unit_id
    add_index :zatrats, :stat_zatr_id
    add_index :sales, :budget_id
    add_index :stat_zatrs, :budget_id
    add_index :stat_zatrs, :spr_stat_zatrs_id
    add_index :naklads, :budget_id
    add_index :naklads, :normativ_id
    add_index :normativ_params, :normativ_core_id
    add_index :normativ_params, :budget_id
  end
end
