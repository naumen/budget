class AddIsDepartmentToDivision < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions, :is_department, :boolean
  end
end
