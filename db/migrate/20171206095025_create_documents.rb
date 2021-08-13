class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string  :filename
      t.string  :content_type
      t.integer :investment_project_id

      t.timestamps
    end
  end
end
