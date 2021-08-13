# Model SprStatZatr
class SprStatZatr < ApplicationRecord
  validates :name, presence: true

  scope :active, -> { where('archived_at IS NULL').order(:name) }

  def self.get_premii_item
    SprStatZatr.find_by_name("ПРЕМИИ")
  end

  def self.get_fot_item
    SprStatZatr.find_by_name("Резерв на ФОТ")
  end

  def archive!
    self.archived_at = Time.now
    self.save
  end

end
