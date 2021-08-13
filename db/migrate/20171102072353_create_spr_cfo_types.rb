class CreateSprCfoTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :spr_cfo_types do |t|
      t.string :name

      t.timestamps
    end

  	SprCfoType.create :name => "Для несводных бюджетов"
  	SprCfoType.create :name => "Бюджет центра доходов"
  	SprCfoType.create :name => "Бюджет центра затрат (накладной)"
  	SprCfoType.create :name => "Бюджет центра прибыли"
  	SprCfoType.create :name => "Бюджет инвестиций уровня компании"
  	SprCfoType.create :name => "Бюджет компании"
  end
end
