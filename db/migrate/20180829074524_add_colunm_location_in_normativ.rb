class AddColunmLocationInNormativ < ActiveRecord::Migration[5.1]
  def change
    add_column :spr_locations, :city, :string
    add_column :spr_locations, :archive_date, :datetime
    add_column :normativ_params, :city, :string
  end
end
