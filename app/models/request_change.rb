class RequestChange < ApplicationRecord
  belongs_to :budget
  has_many   :request_change_actions
  has_many   :request_change_histories
  belongs_to :budget_snapshot, optional: true

  belongs_to :author, class_name: 'User', foreign_key: 'author_id', optional: true

  has_many :request_change_histories, -> { order('id') }
  # s_order
  has_many :request_change_signs, -> { order('id') }

  after_create :save_budget_snapshot

  def delta
    ret = 0.0
    request_change_actions.each do |request_change_action|
      ret += request_change_action.delta
    end
    ret
  end

  # если только одно изменение - на шт.единицу из фот
  def direct_proceed?
    if request_change_actions.size == 1 && request_change_actions.first.action_type == 'state_unit_edit'
      selectedStatZatrFot = request_change_actions.first.content['selectedStatZatrFot'] rescue nil
      return true if selectedStatZatrFot.to_i > 0
    end
    false
  end

  def create_save_action(options)
    if options[:action_id].to_i > 0
      action = RequestChangeAction.find(options[:action_id])
    else
      action = RequestChangeAction.new
      action.request_change_id = self.id
      action.action_type = options[:action_type]
    end
    action.json_content = options[:json_content]
    if action.save
      return "ok"
    else
      return "error"
    end
  end

  # there is any set FOT budget action
  def any_action_set_fot?
    !request_change_actions.select{|a| a.action_type == 'set_budget_fot'}.empty?
  end

  # получение сотрудников заявки ожидают их согласования
  def self.current_confirmation
    # { user_id => [request_change_id, ...], ... }
    ret = {}
    # request_change_id => max_num
    request_change_max_attempts = RequestChangeSign.request_change_max_attempts
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

  def editable?(user)
    self.state == 'Редактируется'
  end

  # согласование пользователем
  def sign(result, user)
    current_sign = self.current_sign
    current_sign_user = self.current_sign.user
    # for TEST
    if Rails.env.development? && user.id == 50
      user = current_sign_user.clone
    end
    if current_sign && current_sign_user == user
      current_sign.result = result
      current_sign.result_date = Time.now
      current_sign.save

      if result == RequestChangeSign::REJECTED
        # отклонение
        self.set_state('Отклонена', user)
        # при отклонении - обнуляем все is_current_attempt
        RequestChangeSign.where(request_change: self).update_all(is_current_attempt: false)
        # уведомление владельцу
        current_sign.send_email_cancelled
      elsif result == RequestChangeSign::CONFIRMED
        # согласование
        if self.is_all_confirmed?
          # если все согласовали - то переводим бюджет в "Утвержден"
          self.set_state('Согласована', user)
          # обрабатываем
          self.proceed(user)
          # уведомление владельцу
          current_sign.send_email_confirmed
        else
          # если есть следующий в цепочке согласования, то
          # посылается на согласование следующему
          current_sign.next_sign.send_email_confirmation
        end
      end
    else
      p "ERROR sign"
    end
  end

  # 'На согласовании'
  # 'Отклонена'
  # 'Согласована'
  def set_state(new_state, current_user)
    self.state = new_state
    if self.save
      if state == 'На согласовании'
        # формирование списка согласователей
        self.init_sign_users(current_user)
        # уведомление
        self.current_sign.send_email_confirmation
      elsif state == 'На редактировании'
        # pass
      end

      # фиксируем историю изменению статусов заявки
      RequestChangeHistory.log(self.id, current_user.id, self.state)      
    end

  end

  def is_all_confirmed?
    self.reload
    RequestChangeSign.is_all_confirmed?(self)
  end

  def current_sign
    RequestChangeSign.current_sign(self)
  end

  def init_sign_users(current_user)
    RequestChangeSign.init_sign(self, current_user)
  end

  # пользователи на согласование
  # добавляем пользователей в список последовательного согласования бюджета
  # если текущий пользователь не равен владельцу - то добавляем владельца бюджета
  # если текущий пользователь - владелец - то пропускаем
  # добавляем владельца из вышестоящего бюджета
  # добавляем ФО
  def request_change_sign_users(current_user)
    ret = []
    ret << self.budget.owner if current_user != self.budget.owner
    ret << self.budget.parent.owner
    ret << User.get_fo_user
    ret.uniq
  end

  def proceed(current_user)
    request_change_actions.each do |a|
      a.handle
    end
    self.set_state('Обработано', current_user)
  end

  def save_budget_snapshot
    bs = BudgetSnapshot.make_snapshot(self.budget)
    self.budget_snapshot = bs
    self.save
  end

  def get_budget_snapshot
    budget_snapshot.restore_snapshot
  end

  def current_signs
    RequestChangeSign.current_signs(self)
  end

  # duplicate?
  def signs_current
    request_change_signs.select{|b| b.is_current_attempt?}
  end

  def signs_old
    request_change_signs.select{|b| !b.is_current_attempt?}
  end


end
