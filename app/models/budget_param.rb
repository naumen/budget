class BudgetParam < ApplicationRecord

  def self.access_budget_report?(user)
    BudgetParam.first.get_budgets_report_access_user_ids.include?(user.id.to_s) || BudgetParam.main_budget_users.map{|i| i[1]}.include?(user.id)
  end

  def self.main_budget_users
    Budget.where(f_year: 2020).all.select{|b| b.budget_type && b.budget_type.name == "Сводный БН"}.map{|b| [b.name, b.owner.id, b.owner.name]}
  end

  def get_budgets_report_access_user_ids
    self.budgets_report_access.to_s.split(',')
  end

  def get_budgets_report_access_users
    User.find(get_budgets_report_access_user_ids)
  end

  def save_budgets_report_access_user_ids(user_ids)
    self.budgets_report_access = user_ids.join(',')
    self.save
  end

  def budgets_report_access_add_user(user)
    user_ids = get_budgets_report_access_user_ids
    user_ids << user.id
    user_ids.uniq!
    save_budgets_report_access_user_ids(user_ids)
  end

  def budgets_report_access_del_user(user)
    user_ids = get_budgets_report_access_user_ids
    user_ids.delete(user.id.to_s)
    save_budgets_report_access_user_ids(user_ids)
  end

end
