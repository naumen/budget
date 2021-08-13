class AddEmploymentTermToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employment_term, :string
  end
end
