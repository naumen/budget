# Model Salary
class Salary < ApplicationRecord

  validates :month, uniqueness: { scope: :state_unit_id,
    message: 'Нельзя дублировать значения по месяцам' }
  belongs_to :state_unit, class_name: 'StateUnit', foreign_key: 'state_unit_id', optional: true
  has_many :budget, through: :state_unit

  def self.as_salaries_start(salaries)
    ret = {}
    cur_salary = salaries[12]
    (1..11).to_a.reverse.each do |m|
      if cur_salary != salaries[m]
        ret[(m+1).to_s] = cur_salary
        cur_salary = salaries[m]
      else
        ret[(m+1).to_s] = ''
      end
    end
    ret["1"] = cur_salary unless ret["1"]
    ret
  end

  def self.import_data_from(url)
    require 'open-uri'

    html = open(url)
    header = html.gets.split(/\t|\n/)

    i = 1
    num = 37

    while i < num
      h = Hash[header.zip html.gets.split(/\t|\n/)]
      Salary.create(h)
      i+=1
    end
  end
end
