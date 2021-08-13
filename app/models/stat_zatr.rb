class StatZatr < ApplicationRecord
  validates :budget_id, presence: true

  belongs_to :budget
  has_many :zatrats, foreign_key: 'stat_zatr_id', dependent: :destroy
  has_many :motivations, -> { where('archived_at IS NULL')}

  belongs_to :spr_stat_zatrs, optional: true, class_name: "SprStatZatr"

  def self.calculate_zatrats(stat_zatr)
    stat_zatr.all_summ = stat_zatr.zatrats.sum('summ')
    stat_zatr.save
  end

  def itogo
    itogo = 0.0
    zatrats.each do |zatrata|
      itogo += zatrata.summ.to_f
    end
    itogo
  end
end
