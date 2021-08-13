class BudgetSign < ApplicationRecord

  belongs_to :budget
  belongs_to :user

  # возвращаем следующего согласователя
  def next_sign
    BudgetSign.where(budget: budget, attempt_num: attempt_num, s_order: s_order + 1).first
  end

  def send_email_confirmation
    BudgetMailer.with(recipient: user, budget: budget).email_confirmation.deliver
  end

  # владельцу бюджета - согласован
  def send_email_confirmed
    BudgetMailer.with(recipient: budget.owner, budget: budget).email_confirmed.deliver
  end

  # владельцу бюджета - отклонен
  def send_email_cancelled
    BudgetMailer.with(recipient: budget.owner, budget: budget).email_cancelled.deliver
  end

  def self.is_all_confirmed?(budget)
    current_signs = self.current_signs(budget)
    result_1_cnt = 0
    current_signs.each do |bs|
      result_1_cnt += 1 if bs.result == 1
    end
    current_signs.size > 0 && current_signs.size == result_1_cnt
  end

  def self.current_signs(budget)
    attempt_number = self.current_attempt_number(budget)
    return [] if attempt_number.nil?
    budget.budget_signs.select{ |bs| bs.attempt_num == attempt_number }
  end

  def self.current_sign(budget, current_attempt=nil)
    current_attempt = self.current_attempt_number(budget) if current_attempt.nil?
    return nil if current_attempt.nil?

    ret = nil
    sql = """
      SELECT id
      FROM budget_signs
      WHERE
        budget_id=#{budget.id}
        AND attempt_num=#{current_attempt}
        AND is_current_attempt=1
        AND result IS NULL
      ORDER BY s_order
      LIMIT 1"""
    result = Budget.connection.select_all(sql)
    if result.rows.size > 0
      sign_id = result.first["id"].to_i
      return BudgetSign.find(sign_id)
    end
    nil
  end

  def self.current_attempt_number(budget)
    attempt_number = nil
    sql = """select attempt_num from budget_signs where budget_id=#{budget.id} order by attempt_num desc limit 1"""
    result = Budget.connection.select_all(sql)
    if result.rows.size > 0
      attempt_number = result.first["attempt_num"].to_i
    end
    attempt_number
  end

  # вызывается при первом переходе на согласование,
  # и так же при переходе на согласование из черновика
  def self.init_sign(budget, current_user)
    s_order = 0
    # получаем либо 1 (если нет), либо следующее значение
    attempt_num = BudgetSign.current_attempt_number(budget).to_i + 1

    # обнуляем все предыдущие
    BudgetSign.where(budget: budget).update_all(is_current_attempt: false)

    # создаем новые
    budget.budget_sign_users(current_user).each do |user|
      s_order += 1
      bs = BudgetSign.new
      bs.budget_id   = budget.id
      bs.user_id     = user.id
      bs.s_order     = s_order
      bs.attempt_num = attempt_num
      bs.is_current_attempt = true
      bs.save
    end
    s_order
  end

  # получение сотрудников у кого бюджеты ожидают их согласования
  def self.current_confirmation
    # { user_id => [b_id, ...], ... }
    ret = {}
    # b_id => max_num
    budget_max_attempts = BudgetSign.budget_max_attempts
    Budget.where( state: "На утверждении", id: budget_max_attempts.keys).each do |b|
      current_attempt = budget_max_attempts[b.id]
      current_sign = BudgetSign.current_sign(b, current_attempt)
      if current_sign
        ret[current_sign.user_id] ||= []
        ret[current_sign.user_id] << b.id
      end
    end
    ret
  end

  def self.budget_max_attempts
    ret = {}
    sql = "select budget_id, max(attempt_num) as max_num from budget_signs group by budget_id"
    result = Budget.connection.select_all(sql)
    result.each do |row|
      b_id      = row['budget_id'].to_i
      max_num   = row['max_num'].to_i
      ret[b_id] = max_num
    end
    ret
  end

end
