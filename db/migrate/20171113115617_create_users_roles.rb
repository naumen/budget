class CreateUsersRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :users_roles do |t|
      t.integer :budget_id
      t.integer :user_id
      t.string :role

      t.timestamps
    end
  end
end
