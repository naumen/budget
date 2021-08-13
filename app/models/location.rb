# Model Location
class Location < ApplicationRecord
  belongs_to :city

  scope :active, -> { where('archived IS NULL')}

  # декретный отпуск
  def self.maternity_leave_location_id
    24
  end

  # свободный человек
  def self.free_location_id
    20
  end

  def self.remote_location_ids
    # 9 Екатеринбург, удаленно
    # 10  Пермь, удаленно
    # 12  Москва, удаленно
    # 18  Крым, удаленно
    # 19  Тверь, удаленно
    # 22  СПб, удаленно    
    [9, 10, 12, 18, 19, 22]
  end

  def archive!
    self.archived = Time.now
    self.save
  end



  # metrik_code_postfix, city_name
  def self.location_metriks
    location_metriks = []
    location_metriks << %w(chel Челябинск)
    location_metriks << %w(ekb Екатеринбург)
    location_metriks << %w(kiev Киев)
    location_metriks << %w(krym Севастополь)
    location_metriks << %w(msk Москва)
    location_metriks << %w(twr Тверь)
    location_metriks << %w(spb Санкт-Петербург)
    location_metriks << %w(kdr Краснодар)
    location_metriks
  end
end
