class AddStateToRequestChange < ActiveRecord::Migration[5.1]
  def change
    add_column :request_changes, :state, :string
  end
end
