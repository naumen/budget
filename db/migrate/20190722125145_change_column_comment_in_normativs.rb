class ChangeColumnCommentInNormativs < ActiveRecord::Migration[5.1]
  def change
    change_column :normativs, :comment, :text
  end
end
