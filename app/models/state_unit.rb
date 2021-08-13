# Model StateUnit
class StateUnit < ApplicationRecord

  validates :budget_id, presence: true

  belongs_to :budget, class_name: 'Budget', foreign_key: 'budget_id'
  belongs_to :user, class_name: 'User', foreign_key: 'user_id', optional: true
  belongs_to :location

  # belongs_to :budget_staff_item
#   belongs_to :position, optional: true

  has_many :salaries, class_name: 'Salary', foreign_key: 'state_unit_id'

  scope :busy, -> { where('user_id IS NOT NULL')}
  scope :vacant, -> { where('user_id IS NULL')}

  after_update :state_unit_after_update

  # 2 nested..
  def get_root_parent_or_self_id
    return self.id if self.parent_id.nil?

    parent_staff_item = StateUnit.find(self.parent_id)
    return parent_staff_item.id if parent_staff_item.parent_id.nil?

    return parent_staff_item.parent_id    
  end

  # update to next year
  def on_update_salary
    state_unit_next = get_in_next_year
    if state_unit_next
      december_salary_summ = self.salaries.where(month: 12).first.summ
      next_year_max_salary_summ = state_unit_next.salaries.map{|s| s.summ}.max
      if december_salary_summ > next_year_max_salary_summ
        state_unit_next.salaries.each do |salary|
          salary.summ = december_salary_summ
          salary.save
        end
      end 

    end
  end

  def state_unit_after_update
    state_unit_next = get_in_next_year
    if state_unit_next
      ["user_id", "rate", "position", "division", "location_id", "archive_date", "staff_item_id", "date_closed", "is_bind"].each do |f_name|
        state_unit_next[f_name] = self[f_name]
      end
      state_unit_next.save
    end
  end

  def clone_to_next_year
    next_budget = self.budget.next_budget
    return if next_budget.nil?
    state_unit = StateUnit.new
    state_unit.parent_id = self.id
    state_unit.budget_id = next_budget.id
    state_unit.f_year    = next_budget.f_year
    ["user_id", "rate", "position", "division", "location_id", "archive_date", "staff_item_id", "date_closed", "is_bind"].each do |f_name|
      state_unit[f_name] = self[f_name]
    end
    state_unit.save
    # salary
    salary_by_december = self.salary_by_december
    if salary_by_december.nil?
      state_unit_salary = 0.0
    else
      state_unit_salary = salary_by_december
    end

    (1..12).to_a.each do |month|
      new_salary = Salary.new
      new_salary.state_unit_id = state_unit.id
      new_salary.summ   = state_unit_salary
      new_salary.f_year = state_unit.f_year
      new_salary.month  = month
      new_salary.save
    end

    state_unit
  end

  def get_in_next_year
    StateUnit.where(parent_id: self.id).first
  end

  # для api v2 выгрузки
  def city_office
    # свободный человек
    return [nil, nil] if self.location_id == Location.free_location_id

    city_id     = self.location.city_id
    location_id = self.location_id

    location_id = nil if Location.remote_location_ids.include?(location_id)

    [city_id, location_id]
  end

  def fio
    !self.user.nil? ? self.user.name : ''
  end

  def in_current_year?
    self.f_year == Time.now.year
  end

  def bind!
    if in_current_year?
      self.is_bind = true
      self.save!
    else
      next_staff_item = self.get_in_next_year
      if next_staff_item
        next_staff_item.is_bind = true
        next_staff_item.save!
      end
    end
  end

  def unbind!
    if in_current_year?
      self.is_bind = false
      self.save!
    else
      next_staff_item = self.get_in_next_year
      if next_staff_item
        next_staff_item.is_bind = false
        next_staff_item.save!
      end
    end
  end

  def bind_to_staff_item(staff_item_id)
    staff_item = nil
    if self.in_current_year?
      staff_item = self
    else
      staff_item = self.get_in_next_year
      return "error" if staff_item.nil?
    end
    return "busy" if !staff_item.staff_item_id.nil?
    staff_item.staff_item_id = staff_item_id
    if staff_item.save
      return "ok"
    else
      return "error"
    end
  end

  def self.free(cfo_id, location_id)
    filter = {}
    filter[:f_year] = 2021
    filter[:staff_item_id] = nil
    filter[:location_id] = location_id if location_id.to_i != 0
    StateUnit.where(filter).all.to_a.delete_if{|s| s.budget.cfo_id.to_i != cfo_id.to_i }
  end

  def self.free_all
    filter = {}
    filter[:f_year] = 2021
    StateUnit.where(filter).all.to_a
  end

  def clone_state_unit
    state_unit = self
    salary_by_december = state_unit.salary_by_december

    f_year_next = self.f_year + 1
    if salary_by_december
      cloned_state_unit = state_unit.dup

      cloned_state_unit.id        = nil
      cloned_state_unit.f_year    = f_year_next
      cloned_state_unit.budget_id = state_unit.budget.next_budget_id
      cloned_state_unit.staff_item_id = state_unit.staff_item_id
      cloned_state_unit.save
      
      state_unit_id = cloned_state_unit.id
      salary        = salary_by_december

      (1..12).to_a.each do |month|
        new_salary = Salary.new
        new_salary.state_unit_id = state_unit_id
        new_salary.summ   = salary
        new_salary.f_year = f_year_next
        new_salary.month  = month
        new_salary.save
      end
    end
  end

  def set_change(info)
    cur_year = 2021
    return "Не корректный год" if !self.new_record? && self.f_year != cur_year
    # if !self.new_record? && self.f_year < cur_year && Rails.env != 'test'
    #   return "Не корректный год" 
    # end

    is_new = self.new_record?

    if self.new_record?
      self.f_year = cur_year
      self.rate   = 1.0
      self.budget_id = info["budget_id"] unless info["budget_id"].blank?
    end

    self.division = info["division"] unless info["division"].blank?
    self.position = info["position"] unless info["position"].blank?
    self.location_id = info["location_id"] if info["location_id"].to_i > 0

    ret_ok = self.save
    if ret_ok
      # pass
    else
      return "Ошибка при сохранении/создании шт. единицы"
    end

    if is_new
      # add salaries
      info["salary_info"].each do |month,val|
        s = Salary.new
        s.state_unit_id = self.id
        s.month = month
        s.f_year  = cur_year
        s.summ  = val
        s.save
      end
    else
      # update salary
      if info["salary_info"]
        salaries.each do |salary|
          if info["salary_info"][salary.month.to_s]
            salary.summ = info["salary_info"][salary.month.to_s].to_s
            salary.save
          end
        end
      end
    end

    # ok
    nil
  end

  def delete
    return false if self.staff_item_id
    salaries.each do |salary|
      salary.destroy
    end
    self.destroy
  end

  def self.update_from_hr2(do_changes=nil)
    nil
  end

  # id => name
  def self.hr2_positions
  end

  # id => name
  def self.hr2_divisions
  end

  def self.reload_occupied(is_test=false)
  end

  def fzp
    itogo = 0.0
    salaries.each do |salary|
      itogo += salary.summ
    end
    itogo
  end

  def salaries_as_array
    ret = []
    salaries.each do |salary|
      ret << [salary.month, salary.summ]
    end
    ret
  end
  
  def salaries_as_hash
    ret = {}
    salaries.each do |salary|
      ret[salary.month] = salary.summ
    end
    ret
  end
  
end
