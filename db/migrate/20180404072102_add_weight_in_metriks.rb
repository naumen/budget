class AddWeightInMetriks < ActiveRecord::Migration[5.1]
  def change
    Metrik.create(id: 6, name: 'По весу', code: 'by_weight')
  end
end
