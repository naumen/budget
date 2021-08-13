# Model StaffItemSalary
class StaffItemSalary < ApplicationRecord

  MONTHS = {
      '1': "Январь",
      '2': "Февраль",
      '3': "Март",
      '4': "Апрель",
      '5': "Май",
      '6': "Июнь",
      '7': "Июль",
      '8': "Август",
      '9': "Сентябрь",
      '10': "Октябрь",
      '11': "Ноябрь",
      '12': "Декабрь"
  }


  def self.months
    MONTHS
  end

  def month_name
    StaffItemSalary.months[f_month.to_s.to_sym]
  end

  def self.import
  end

end
