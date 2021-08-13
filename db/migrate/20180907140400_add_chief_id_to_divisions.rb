class AddChiefIdToDivisions < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions, :chief_id, :integer
  end
end
