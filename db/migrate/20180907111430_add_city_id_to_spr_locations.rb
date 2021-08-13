class AddCityIdToSprLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :spr_locations, :city_id, :integer
  end
end
