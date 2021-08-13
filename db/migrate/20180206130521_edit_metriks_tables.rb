class EditMetriksTables < ActiveRecord::Migration[5.1]
  def change
    Metrik.delete_all

    Metrik.create( id: 1, name: 'Кол-во штатных единиц в локации',           code: 'location_state_unit' )
    Metrik.create( id: 2, name: 'Кол-во вакантных штатных единиц в локации', code: 'state_units_vakant' )
    Metrik.create( id: 3, name: 'Кол-во месячных затрат ШЕ в локации',       code: 'month_location_state_unit' )
    Metrik.create( id: 4, name: 'Общий объем ФЗП',                           code: 'fzp' )
    Metrik.create( id: 5, name: 'Объем продаж через канал',                  code: 'sales_total' )

    add_column :budget_metriks, :location_id, :integer
    add_column :budget_metriks, :sale_channel_id, :integer
    add_column :state_units,    :location_id, :integer

    create_table :spr_locations do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    SprLocation.create( id: 1, name: "Екатеринбург",    code: "ekb" )
    SprLocation.create( id: 2, name: "Москва",          code: "msk" )
    SprLocation.create( id: 3, name: "Севастополь",     code: "svs" )
    SprLocation.create( id: 4, name: "Санкт-Петербург", code: "spb" )
  end
end
