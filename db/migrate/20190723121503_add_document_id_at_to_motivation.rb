class AddDocumentIdAtToMotivation < ActiveRecord::Migration[5.1]
  def change
    add_column :motivations, :document_id, :integer
  end
end
