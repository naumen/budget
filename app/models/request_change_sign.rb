# t.integer :request_change_id
# t.integer :user_id
# t.integer :s_order
# t.integer :attempt_num
# t.boolean :is_current_attempt
# t.integer :result
# t.timestamp :result_date
# t.text :comment

class RequestChangeSign < ApplicationRecord

  belongs_to :request_change
  belongs_to :user

  RequestChangeSign::CONFIRMED = 1
  RequestChangeSign::REJECTED  = 0

  # возвращаем следующего согласователя
  def next_sign
    RequestChangeSign.where(request_change: request_change, attempt_num: attempt_num, s_order: s_order + 1).first
  end

  def confirmed?
    self.result == RequestChangeSign::CONFIRMED
  end

  def rejected?
    self.result == RequestChangeSign::REJECTED
  end

  # согласование участнику согласования
  def send_email_confirmation
    RequestChangeMailer.with(recipient: self.user, request_change: self.request_change).email_confirmation.deliver
  end

  # владельцу бюджета - согласован
  def send_email_confirmed
    RequestChangeMailer.with(recipient: request_change.budget.owner, request_change: request_change).email_confirmed.deliver
  end

  # владельцу бюджета - отклонен
  def send_email_cancelled
    RequestChangeMailer.with(recipient: request_change.budget.owner, request_change: request_change).email_cancelled.deliver
  end

  def self.is_all_confirmed?(request_change)
    current_signs = RequestChangeSign.current_signs(request_change)
    result_confirm_cnt = 0
    current_signs.each do |s|
      result_confirm_cnt += 1 if s.result == RequestChangeSign::CONFIRMED
    end
# p "is_all_confirmed?"
# p result_confirm_cnt
    current_signs.size > 0 && current_signs.size == result_confirm_cnt
  end

  def self.current_signs(request_change)
    attempt_number = RequestChangeSign.current_attempt_number(request_change)
    return [] if attempt_number.nil?
    request_change.request_change_signs.select{ |s| s.attempt_num == attempt_number }
  end

  def self.current_sign(request_change, current_attempt=nil)
    current_attempt = RequestChangeSign.current_attempt_number(request_change) if current_attempt.nil?
    return nil if current_attempt.nil?

    rows = RequestChangeSign.where(
      request_change_id:  request_change.id,
      attempt_num:        current_attempt,
      is_current_attempt: true,
      result:             nil).order(:s_order).limit(1)
    if rows.size > 0
      return rows[0]
    end
    nil
  end

  def self.current_attempt_number(request_change)
    attempt_number = nil
    sql = """select attempt_num from request_change_signs where request_change_id=#{request_change.id} order by attempt_num desc limit 1"""
    result = Budget.connection.select_all(sql)
    if result.rows.size > 0
      attempt_number = result.first["attempt_num"].to_i
    end
    attempt_number
  end

  # вызывается при первом переходе на согласование,
  # и так же при переходе на согласование из черновика
  def self.init_sign(request_change, current_user)
    s_order = 0
    # получаем либо 1 (если нет), либо следующее значение
    attempt_num = RequestChangeSign.current_attempt_number(request_change).to_i + 1

    # обнуляем все предыдущие
    RequestChangeSign.where(request_change: request_change).update_all(is_current_attempt: false)

    # создаем новые
    request_change.request_change_sign_users(current_user).each do |user|
      s_order += 1
      bs = RequestChangeSign.new
      bs.request_change_id   = request_change.id
      bs.user_id     = user.id
      bs.s_order     = s_order
      bs.attempt_num = attempt_num
      bs.is_current_attempt = true
      bs.save
    end
    s_order
  end

  # получение сотрудников у кого заявки ожидают их согласования
  def self.current_confirmation
    # { user_id => [request_change_id, ...], ... }
    ret = {}
    # b_id => max_num
    budget_max_attempts = RequestChangeSign.request_change_max_attempts
    RequestChange.where( state: "На согласовании", id: request_change_max_attempts.keys).each do |r|
      current_attempt = request_change_max_attempts[r.id]
      current_sign = RequestChangeSign.current_sign(r, current_attempt)
      if current_sign
        ret[current_sign.user_id] ||= []
        ret[current_sign.user_id] << r.id
      end
    end
    ret
  end

  def self.request_change_max_attempts
    ret = {}
    sql = "select request_change_id, max(attempt_num) as max_num from request_change_signs group by request_change_id"
    result = Budget.connection.select_all(sql)
    result.each do |row|
      b_id      = row['request_change_id'].to_i
      max_num   = row['max_num'].to_i
      ret[b_id] = max_num
    end
    ret
  end

end
