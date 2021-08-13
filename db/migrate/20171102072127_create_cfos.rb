class CreateCfos < ActiveRecord::Migration[5.1]
  def change
    create_table :cfos do |t|
  	  t.string :name

      t.timestamps
  	end

  	Cfo.create :name => "ЦФО_1"
  	Cfo.create :name => "ЦФО_2"
  	Cfo.create :name => "ЦФО_3"
  end
end
