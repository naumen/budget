class CreateRequestChangeActions < ActiveRecord::Migration[5.1]
  def change
    create_table :request_change_actions do |t|
      t.integer :request_change_id
      t.string :action_type
      t.text :json_content

      t.timestamps
    end
  end
end
