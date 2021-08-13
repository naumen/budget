# Model StaffItem
class StaffItem < ApplicationRecord
  # belongs_to :division
  # belongs_to :position
  # belongs_to :user_staff, optional: true
  # belongs_to :location, class_name: 'SprLocation', optional: true

  has_many :staff_item_salaries, -> { where archive_date: nil }

  def city_id
    Location.find(self.location_id).city_id
  end

  def archived
    nil
  end

  def current_salary
    salary = staff_item_salaries.where(["f_month <= ?", Time.now.month]).order('f_month DESC').first
    salary ? salary.salary : nil
  end

  def self.import
  end

end
