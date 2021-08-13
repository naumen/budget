class CreateRequestChangeHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :request_change_histories do |t|
      t.integer :request_change_id
      t.string :state
      t.integer :user_id
      t.string :timestamps

      t.timestamps
    end
  end
end
