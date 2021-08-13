# Model Budget
#
#
class Budget < ApplicationRecord

  # комментировать при импорте
  # и после - Budget.rebuild!
  acts_as_nested_set

  validates :name, :f_year, presence: true
   # :currency, :budget_type_id,

  has_many :stat_zatr, class_name: 'StatZatr', foreign_key: 'budget_id', dependent: :destroy
#   has_many :sale, class_name: 'Sale', foreign_key: 'budget_id', dependent: :destroy
#
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id', optional: true
  belongs_to :budget_type, class_name: 'BudgetType', foreign_key: 'budget_type_id', optional: true

  has_many :state_units, class_name: 'StateUnit', foreign_key: 'budget_id'

  has_many :busy_state_units,   -> { busy },   class_name: 'StateUnit', foreign_key: 'budget_id'
  has_many :vacant_state_units, -> { vacant }, class_name: 'StateUnit', foreign_key: 'budget_id'
  has_many :normativs
  has_many :sales
  has_many :request_changes

  #   has_many :salaries, class_name: 'Salary', through: :state_units
#
  has_many :users_role, :class_name => 'UsersRole', dependent: :destroy
  has_many :users, through: :users_role

  has_many :budget_histories, -> { order('id') }
  has_many :budget_signs, -> { order('id') }

  has_many :documents, -> { where("archived_at IS NULL").order('id') }, as: :owner

  #
  def stat_zatr_fot_items
    ret = []
    fot_stat_zatr = self.get_fot_stat_zatr
    if fot_stat_zatr
      ret << { name: fot_stat_zatr.name, id: fot_stat_zatr.id, value: fot_stat_zatr.itogo }
    end
    ret
  end

  # def stat_zatr_fot_items
  #   ret = []
  #   self_or_top_fot_stat_zatr = self.get_self_or_top_fot_stat_zatr
  #   if self_or_top_fot_stat_zatr
  #     ret << {
  #       name:  self_or_top_fot_stat_zatr.name + " [#{self_or_top_fot_stat_zatr.budget.name}]",
  #       id:    self_or_top_fot_stat_zatr.id,
  #       value: self_or_top_fot_stat_zatr.itogo
  #     }
  #   end
  #   ret
  # end



  def get_self_or_top_fot_stat_zatr
    self_fot_stat_zatr = self.get_fot_stat_zatr
    return self_fot_stat_zatr if self_fot_stat_zatr
    cfo_id = self.cfo_id
    return nil if cfo_id.nil?
    self.ancestors.reverse.each do |b|
      return nil if b.cfo_id != cfo_id
      top_fot_stat_zatr = b.get_fot_stat_zatr
      return top_fot_stat_zatr if top_fot_stat_zatr
    end
    nil
  end

  def state_units_info
    ret = []
    self.state_units.each do |state_unit|
      row = {}
      row[:id] = state_unit.id
      row[:position] = state_unit.position
      row[:division] = state_unit.division
      row[:location] = state_unit.location.name
      row[:location_id] = state_unit.location_id
      row[:fio]         = state_unit.fio
      row[:salaries] = state_unit.salaries_as_array
      row[:salaries_start] = Salary.as_salaries_start(state_unit.salaries_as_hash) # wtf

      ret << row
    end
    ret
  end

  def state_units_as_json
    state_units_info.to_json
  end

  # division, position, location_id
  def self.restore_state_unit(state_unit_id, budget_snapshot)
    ret = {}
    state_unit = Budget.get_state_unit_from_snapshot(state_unit_id, budget_snapshot)
    if state_unit
      ["division", "position", "location_id", "location"].each do |f_name|
        ret[f_name] = state_unit[f_name]
      end
    end
    ret
  end

  # salaries_as_hash
  def self.restore_state_unit_salaries(state_unit_id, budget_snapshot)
    ret = {}
    state_unit = Budget.get_state_unit_from_snapshot(state_unit_id, budget_snapshot)
    if state_unit
      state_unit["salaries"].each do |month_value|
        ret[month_value[0]] = month_value[1].to_f
      end
    end
    ret
  end

  def self.get_state_unit_from_snapshot(state_unit_id, budget_snapshot)
    budget_snapshot["state_units"].each do |state_unit|
      return state_unit if state_unit["id"].to_i == state_unit_id.to_i
    end
    nil
  end

  # бюджеты по которым расчитываем средний расход на шт. единицу
  # это сервисные бюджеты по локациям из группы "Накладные локаций",
  # значение шт.единиц - берём из БН
  def self.budget_normativ_avg
    # [year, budget_id, metrik_id, name]
    rows = []
    rows
  end

  def show_normativ_avg?
    ids = Budget.budget_normativ_avg.map{|r| r[1]}
    ids.include?(self.id)
  end

  def info_normativ_avg(budget_info)
    info = {}
    info
  end

  def self.get_report(f_year, budget_ids, include_prev_year = false)
    prev_f_year = f_year - 1
    ret = {}

    ret[:budget_params] = []
    budget_params = []
    budget_params << ["Продажи", 'руб']
    budget_params << ["Расходы", 'руб']
    budget_params << ["Планируемая рентабельность", '%']
    budget_params << ["Планируемая выручка на одного сотрудника", 'руб']
    budget_params << ["Планируемая доходность на одного сотрудника", 'руб']
    budget_params << ["Среднемесячная ЗП", 'руб']
    budget_params << ["Выручка на рубль з/п", 'руб']

    ret[:budget_params] = budget_params

    ret[:rows] = []

    Budget.where(f_year: f_year).all.each do |budget|
      next if !budget_ids.include?(budget.id)

      budget_presenter = BudgetPresenter.new(budget)
      budget_presenter.is_for_report = true
      budget_parameters = budget_presenter.budget_parameters

      if include_prev_year
        prev_budget_presenter = BudgetPresenter.new(budget.prev_budget)
        prev_budget_presenter.is_for_report = true
        prev_budget_parameters = prev_budget_presenter.budget_parameters
      end
      row = {
        budget_name: budget.name,
        budget_id: budget.id,
        budget_params: {}  # param_name => { year => obj, ... }
      }
      row[:budget_params][f_year] = {}; budget_parameters.each{|b_p| row[:budget_params][f_year][b_p[:name]] = b_p }
      if prev_budget_parameters
        row[:budget_params][prev_f_year] = {}; prev_budget_parameters.each{|b_p| row[:budget_params][prev_f_year][b_p[:name]] = b_p }
      end
      ret[:rows] << row
    end
    ret
  end


  def allow_request_change_create?
    return true if Rails.env == 'development'
    ['Утвержден', 'На утверждении'].include?(state)
  end

  def show_request_change?
    request_changes.size > 0 || allow_request_change_create?
  end

  def self.budget_ids_for_year(f_year)
    Budget.where(f_year: f_year).all.map{|b| b.id}
  end

  def get_metrik_changes
    ret = {}
    time_points = _get_time_points
    prev_metriks = nil
    time_points.each do |time|
      m = _get_metriks_on_time(time)
      if prev_metriks.nil?
        prev_metriks = m
        next
      end

      metrik_diff = _compare_metriks(prev_metriks, m)
      unless metrik_diff.empty?
        ret[time] = metrik_diff
      end
      prev_metriks = m
    end
    ret.reverse_each.to_h
  end

  def _get_time_points
    BudgetMetrik.where(budget_id: self.id).all.map{|bm| bm.archived_at.to_s}.uniq
  end

  def _get_metriks_on_time(time)
    ret = {} # metrik_id => value
    time = nil if time == ''
    b_metriks = BudgetMetrik.where(budget_id: self.id, archived_at: time)
    b_metriks.each do |b_m|
      ret[b_m.metrik_id] = b_m.value
    end
    ret
  end

  # old, new
  def _compare_metriks(m1, m2)
    ret = {} # metrik_id => [old, new]
    m1.each do |m_id, val|
      if m2[m_id] == val
        # skip
      else
        # отсутсвует в новой версии
        # или изменение
        ret[m_id] = [val, m2[m_id]]
      end
    end

    # проверка на отсутствие старой версии
    m2.each do |m_id, val|
      if m1[m_id].nil?
        ret[m_id] = [nil, val]
      end
    end
    ret
  end

  def self.budget_info_to_json(budget_info)
    ret = {}
    # ret[:in]  = {}

    ret[:out] = {}
    ret[:out][:own] = {
      zatratas: '%.2f' % budget_info.out.own.zatratas.to_f,
      nakladn:  '%.2f' % budget_info.out.own.nakladn.to_f,
      salary:   '%.2f' % budget_info.out.own.salary.to_f,
      invest:   '%.2f' % budget_info.out.own.invest.to_f
    }

    ret[:out][:sub] = {
      zatratas: '%.2f' % budget_info.out.sub.zatratas.to_f,
      nakladn:  '%.2f' % budget_info.out.sub.nakladn.to_f,
      salary:   '%.2f' % budget_info.out.sub.salary.to_f,
      invest:   '%.2f' % budget_info.out.sub.invest.to_f
    }

    ret.to_json
  end

  def as_json
    ret = {}
    fields = ['name', 'f_year']
    fields.each do |f|
      ret[f] = self[f]
    end

    # stat_zatrs
    stat_zatrs = []
    self.stat_zatr.each do |sz|
      _stat_zatr = {}
      ['id', 'spr_stat_zatrs_id', 'name'].each do |f|
        _stat_zatr[f] = sz[f]
      end
      _stat_zatr['zatratas'] = []
      sz.zatrats.each do |z|
        _stat_zatr['zatratas'] << {
          month:     z.month,
          summ:      z.summ,
          is_beznal: z.nal_beznal
        }
      end
      stat_zatrs << _stat_zatr
    end
    ret['stat_zatrs'] = stat_zatrs

    # salaries
    ret['state_units'] = state_units_info

    ret.to_json
  end

  def is_deletable?(cur_user)
    stat_zatr.size == 0      \
      && cur_user.is_admin?  \
      && real_childrens.size == 0  \
      && state == 'Черновик' \
      && normativs.size == 0 \
      && sales.size == 0
  end

  # w/o archived
  def real_childrens
    children.to_a.delete_if{|c| c.archived}
  end

  def delete(cur_user)
    if is_deletable?(cur_user)
      self.archived = Time.now
      return self.save
    else
      false
    end
  end


  def budget_signs_current
    budget_signs.select{|b| b.is_current_attempt?}
  end

  def budget_signs_old
    budget_signs.select{|b| !b.is_current_attempt?}
  end

  belongs_to :prev_budget, class_name: 'Budget', foreign_key: 'prev_budget_id', optional: true
  belongs_to :next_budget, class_name: 'Budget', foreign_key: 'next_budget_id', optional: true

  belongs_to :cfo, foreign_key: 'cfo_id', optional: true

  def set_fot_delta_value(delta_value, user=nil, request_change=nil)
    set_fot_value(nil, user, request_change, delta_value)
  end

  def set_fot_value(value, user=nil, request_change=nil, delta_value=nil)

    value = value.to_f

    fot_stat_zatr = get_fot_stat_zatr
    cur_value = self.fot_value

    if fot_stat_zatr
      zatrat = fot_stat_zatr.zatrats.first
      if delta_value
        zatrat.summ += delta_value.to_f
      else
        zatrat.summ = value
      end      
      zatrat.save
    else
      spr_fot  = SprStatZatr.get_fot_item

      stat_zatr = StatZatr.new
      stat_zatr.budget_id = self.id
      stat_zatr.name      = spr_fot.name
      stat_zatr.spr_stat_zatrs_id = spr_fot.id
      stat_zatr.f_year = self.f_year
      stat_zatr.save

      zatrat = Zatrat.new
      zatrat.stat_zatr_id = stat_zatr.id
      zatrat.month = 12
      zatrat.f_year = self.f_year
      if delta_value
        zatrat.summ = delta_value.to_f
      else
        zatrat.summ = value
      end      
      zatrat.save
    end

    log = FotLog.new
    log.stat_zatr_id = Budget.find(self.id).get_fot_stat_zatr.id
    log.budget_id    = self.id
    log.user_id = user.id if user

    if delta_value
      log.delta   = delta_value
      log.summa   = zatrat.summ
    else
      log.summa   = value
      log.delta   = value - cur_value
    end

    log.request_change_id = request_change.id if request_change
    log.save
    # fot_logs
    # t.integer :stat_zatr_id
    # t.integer :user_id
    # t.decimal :summa, precision: 15, scale: 2
    # t.decimal :delta, precision: 15, scale: 2
  end

  def get_fot_stat_zatr
    spr_fot  = SprStatZatr.get_fot_item
    self.stat_zatr.select{|z| z.spr_stat_zatrs == SprStatZatr.get_fot_item }.first
  end

  def fot_value
    spr_fot  = SprStatZatr.get_fot_item
    sql = """
      SELECT
        stat_zatrs.budget_id as budget_id,
        SUM(zatrats.summ) as summa
      FROM
        zatrats,
        stat_zatrs
      WHERE
        stat_zatrs.spr_stat_zatrs_id = #{spr_fot.id}
        AND stat_zatrs.budget_id = #{self.id}
        AND zatrats.stat_zatr_id = stat_zatrs.id
      GROUP BY
        stat_zatrs.budget_id
    """
    items = Budget.connection.select_all(sql)
    return 0.0 if items.empty?
    items.first["summa"].to_f
  end

  def self.ticket_db?
    # Rails.env == 'development' && 
    Rails.application.config.database_configuration.keys.include?("ticket_database")
  end

  def checkbooks
    Checkbook.checkbooks(self.id)
  end

  # бюджеты с этими ид не должны пробрасывать наверх свои метрики
  def self.sub_budget_ids
    []
  end

  def is_sub_budget?
    Budget.sub_budget_ids.include?(self.id)
  end

  def editable?
    self.state == 'Черновик' || self.state == 'На доработке'
  end

  # доступ на редактирование бюджета - для администратора, владельца, редактора
  # доступ на управление доступом к бюджету - только администратор, и владелец
  # ссылка на добавление продаж - доступа админу и редактору
  # ссылка на добавление статей затрат - доступна админу и редактору
  # ссылка на добавление под бюджета - доступа админу и редактору
  def allow?(permision, user)

    return true if permision == 'link_edit_state_unit' && user.is_superadmin?

    return true if self.allow_request_change_create? && permision=='link_new_request_change' && (user.is_admin? || (self.owner && self.owner == user) || self.access?(user) == "editor" )

    # доступ к бюджету можно изменять для закрытых бюджетов
    return true if permision == "link_users_roles" && (user.is_admin? || (self.owner && self.owner == user))

    # доступ на карточку ФОТ отчета, и на корневой бюджет для HR менеджера
    if permision == "show_budget_fot_report" && user.is_admin?
      return true
    end

    # доступ на карточку ФОТ отчета, и на корневой бюджет для HR менеджера
    if "show_budget_fot_report" == permision
      if user.is_admin? || self.access?(user) == "editor" || ([80001, 90001, 100001].include?(self.id) && user.hr_manager?)
        return true
      end
    end

    # если не редактируется тогда нет доступа
    return false if !self.editable?

    case permision

    when "link_edit_budget"
      user.is_admin? || (self.owner && self.owner == user) || self.access?(user) == "editor"

    when "link_new_sale"
      user.is_admin? || self.access?(user) == "editor"

    when "link_new_stat_zatr"
      user.is_admin? || self.access?(user) == "editor"

    when "link_new_childbudget"
      user.is_admin? || self.access?(user) == "editor"

    when "link_new_state_unit", "link_edit_state_unit"
      (user.is_admin? || self.access?(user) == "editor") && self.f_year >= 2020

    else
      false
    end
  end

  def clone_to_next_year
    cloned = self.dup

    cloned.id = nil
    cloned.f_year         = self.f_year + 1
    cloned.prev_budget_id = self.id
    cloned.parent_id      = self.parent.next_budget.id
    cloned.state          = 'Черновик'
    if cloned.save
      cloned_budget_id = cloned.id
      self.next_budget_id = cloned_budget_id
      self.save

      self.clone_stat_zatrs_and_zatrats

      return true
    else
      return false
    end
  end

  def init_sign_users(current_user)
    BudgetSign.init_sign(self, current_user)
  end

  # пользователи на согласование
  # добавляем пользователей в список последовательного согласования бюджета
  # если текущий пользователь не равен владельцу - то добавляем владельца бюджета
  # если текущий пользователь - владелец - то пропускаем
  # добавляем владельца из вышестоящего бюджета
  def budget_sign_users(current_user)
    ret = []
    ret << self.owner if current_user != self.owner
    ret << self.parent.owner
    ret.uniq
  end

  def self.budget_type_ids_for_nakladn_matrix
    [10, 11, 4]
#     4	Инвестиционный компании
#     5	инвестиционный направления
#     6	Маркетинг
#     7	Сводный компании
#     10	Сводный БН
#     11	Сводный СН
  end

  def self.invest_type_ids
    #     4	Инвестиционный компании
    #     5	инвестиционный направления
    ret = []
    # , "инвестиционный направления"
    ["Инвестиционный компании", "Инвестиционный направления"].each do |name|
      ret << BudgetType.find_by_name(name).id
    end
    ret
  end

  def show_budget_parameters?
    # 10	Сводный БН
    # 11	Сводный СН
    [10, 11].include?(budget_type_id)
  end

  def is_top?
    parent.nil?
  end

  def self.top_budget(f_year)
    return Budget.where( f_year: f_year, parent_id: nil).first
  end

  def fin_year
    f_year
  end

  def get_children_sales()
    #budgets_ids = Budget.get_tree_budgets_for(self.children, true).pluck(:id)
    budgets_ids = self.descendants.pluck(:id)

    budget_sales = Sale.where(budget_id: budgets_ids)
    budget_sales.sum(:summ)
  end

  def get_children_stat_zatr()
    #budgets_ids = Budget.get_tree_budgets_for(self.children, true).pluck(:id)
    budgets_ids = self.descendants.pluck(:id)

    itog = 0
    budget_stat_zatr = StatZatr.where(budget_id: budgets_ids)
    budget_stat_zatr.each do |stat_zatr|
      itog += stat_zatr.zatrats.sum(:summ)
    end
    itog
  end

  def self.get_breadcrumbs(budget, first = false)
    @bread = @bread.nil? || first ? [] : @bread
    @bread.unshift(budget) if !first
    unless budget.parent.nil?
      Budget.get_breadcrumbs(budget.parent)
    end

    @bread
  end

  def self.get_tree_budgets_for(budgets, first = false)
    @budget_tree = first ? [] : @budget_tree

    budgets.each do |budget|
      @budget_tree.push budget
      unless budget.children.empty?
        Budget.get_tree_budgets_for(budget.children)
      end
    end

    @budget_tree
  end

  def self.budget_empty?(budget)
    if   budget.children.empty?                          \
      && budget.sale.empty?                               \
      && budget.stat_zatr.empty?                           \
      && budget.filling_investment_project.empty?           \
      && budget.filling_investment_project.empty?
      { confirm: 'Вы уверены, что хотите удалить этот бюджет?' }
    else
      { confirm: '!!!В бюджете есть зависимые объекты!!! \n\nВы уверены, что хотите удалить бюджет со всеми вложениями?' }
    end
  end

  def self.children_zatrats(budget)
    children_zatrats = 0.0
    budget.children.each do |child|
      children_zatrats += child.all_zatrats_summ
    end

    children_zatrats
  end

  def normativs_summ
    summ = 0
    self.normativ.each do |normativ|
      summ += normativ.normativ_core.naklads.actual.sum('summ')
    end
    summ
  end

  def self.itogi_dohods(budget)
    itog_dohod = 0

    itog_dohod += budget.normativs_summ

    budget.filling_investment_project.each do |investment_project|
      itog_dohod += investment_project.summ
    end

    itog_dohod += budget.sale.sum(:summ)
    itog_dohod += budget.get_children_sales

    itog_dohod += Budget.children_naklads_dohods(budget)
    itog_dohod += Budget.children_investment_project_dohods(budget)
    itog_dohod += budget.credit_invest_loans.sum('summ')
    itog_dohod += budget.use_repayment_loans.sum('summ')
    itog_dohod += Budget.children_invest_loans_dohods(budget)
  end

  def self.itogi_rashods(budget)
    itog_rashod = 0

    itog_rashod += budget.naklads.sum('summ')

    budget.use_investment_project.each do |investment_project|
      itog_rashod += investment_project.summ
    end

    itog_rashod += budget.get_children_stat_zatr

    budget.stat_zatr.each do |stat_zatr|
      itog_rashod += stat_zatr.zatrats.sum(:summ)
    end

    itog_rashod += budget.salaries.where(f_year: budget.f_year).sum(:summ)
    itog_rashod += Budget.children_naklads_zatrats(budget)
    itog_rashod += Budget.children_investment_project_zatrats(budget)
    itog_rashod += Budget.children_salary(budget)
    itog_rashod += budget.use_invest_loans.sum('summ')
    itog_rashod += budget.filling_repayment_loans.sum('summ')
    itog_rashod += Budget.children_invest_loans_zatrats(budget)
  end

  def self.itogi_raznica(budget)
    Budget.itogi_dohods(budget)  - Budget.itogi_rashods(budget)
  end

  def self.def_prof(budget)
    Budget.itogi_raznica(budget) - budget.plan_marga
  end

  def self.what_level(budget)
    level = 0
    while !budget.parent.nil? do
      budget = budget.parent
      level += 1
    end

    level
  end

  def self.children_naklads_dohods(budget)
    normativs = NormativParam.where(closed_at: nil)
    normativ_budgets = []
    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants

    normativs.each do |normativ|
      if budget_tree.include? normativ.budget
        normativ_budgets.push (normativ)
      end
    end

    naklads_dohods_summ = 0.0
    normativ_budgets.each do |normativ|
      normativ.normativ_core.naklads.each do |naklad|
        if !budget_tree.include? naklad.budget
          naklads_dohods_summ += naklad.summ
        end
      end
    end

    naklads_dohods_summ
  end

  def self.children_naklads_zatrats(budget)
    naklads = Naklad.actual
    naklads_budgets = []

    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants

    naklads.each do |naklad|
      if budget_tree.include? naklad.budget
        naklads_budgets.push (naklad)
      end
    end
    naklads_zatrats_summ = 0.0
    naklads_budgets.each do |naklad|
      if naklad.normativ && (!budget_tree.include? naklad.normativ.normativ_params.find_by(closed_at: nil).budget)
        naklads_zatrats_summ += naklad.summ
      end
    end

    naklads_zatrats_summ.to_f
  end

  def self.children_investment_project_dohods(budget)
    investment_project = InvestmentProject.all

    investment_project_dohods_summ = 0.0

    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants


    investment_project.each do |investment_project|
      if (budget_tree.include? investment_project.filling_budget) && (!budget_tree.include? investment_project.use_budget)
        investment_project_dohods_summ += investment_project.summ
      end
    end

    investment_project_dohods_summ
  end

  def self.children_investment_project_zatrats(budget)
    investment_project = InvestmentProject.all

    investment_project_zatrats_summ = 0.0

    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants


    investment_project.each do |investment_project|
      if (budget_tree.include? investment_project.use_budget) && (!budget_tree.include? investment_project.filling_budget)
        investment_project_zatrats_summ += investment_project.summ
      end
    end

    investment_project_zatrats_summ
  end

  def self.children_salary(budget)
    salary_summ = 0.0

    budget.descendants.each do |budget|
      budget.state_units.each do |state_unit|
        salary_summ += state_unit.salaries.sum(:summ)
      end
    end

    #budget_tree_ids = Budget.get_tree_budgets_for(budget.children, true).map{ |b| b.id }
    # salaries.each do |salary|
    #   next if salary.state_unit.nil?
    #   budget_id = salary.state_unit.budget_id
    #   if (budget_tree_ids.include? budget_id)
    #     salary_summ += salary.summ
    #   end
    # end

    salary_summ
  end

  def self.children_invest_loans_zatrats(budget)
    invest_loan = InvestLoan.all

    invest_loan_dohods_summ = 0.0

    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants


    invest_loan.each do |invest_loan|
      if (budget_tree.include? invest_loan.use_budget) && (!budget_tree.include? invest_loan.credit_budget)
        invest_loan_dohods_summ += invest_loan.summ
      end
    end

    invest_loan_dohods_summ
  end

  def self.children_invest_loans_dohods(budget)
    invest_loan = InvestLoan.all
    repayment_loan = RepaymentLoan.all

    invest_loan_zatrats_summ = 0.0

    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants


    invest_loan.each do |invest_loan|
      if (!budget_tree.include? invest_loan.use_budget) && (budget_tree.include? invest_loan.credit_budget)
        invest_loan_zatrats_summ += invest_loan.summ
      end
    end

    invest_loan_zatrats_summ
  end

  def self.migrate_from_last_year(last_year)
    budget = Budget.roots.find_by(f_year: last_year)

    #budget_tree = Budget.get_tree_budgets_for(budget.children, true)
    budget_tree = budget.descendants.to_a

    budget_tree.unshift(budget)

    budget_tree.each do |budget|
      new_budget = budget.dup
      new_budget.id = budget.id + 10000
      new_budget.all_zatrats_summ = 0
      new_budget.all_dohods_summ = 0
      new_budget.f_year = last_year + 1
      new_budget.prev_budget_id = budget.id
      new_budget.next_budget_id = nil
      new_budget.parent_id = budget.parent_id.to_i + 10000 if budget.parent_id != nil
      new_budget.itogo_usage = 0.0
      new_budget.budget_info = nil
      new_budget.itogo_in    = 0.0
      new_budget.state       = 'Черновик'
      new_budget.save
      budget.next_budget_id = new_budget.id
      budget.save
    end

    Budget.reset_column_information
    Budget.rebuild!
  end

  def self.give_me_budget_in_year(budget, year)
    if budget.f_year < year
      begin
        new_budget = Budget.find((budget.id + (year - budget.f_year) * 10000))
      rescue ActiveRecord::RecordNotFound
        return nil
      end
    elsif budget.f_year > year
      begin
        new_budget = Budget.find((budget.id - (budget.f_year - year) * 10000))
      rescue ActiveRecord::RecordNotFound
        return nil
      end
    else
      new_budget = budget
    end

    new_budget
  end

  def get_metriks
    # budgets_ids = Budget.get_tree_budgets_for(self.children, true).pluck(:id)
    budgets_ids = self.self_and_descendants.pluck(:id)

    # budgets_ids.unshift(self.id)

    budget_metriks = BudgetMetrik.where(budget_id: self.id)

    itog_metriks = []

    itog_metriks
    budget_metriks
  end

  def generate_statistics
    budget_filling = 0
    budget_filling += self.normativs_summ
    budget_filling += self.sale.sum(:summ)
    budget_filling += self.get_children_sales
    budget_filling += Budget.children_naklads_dohods(self)
    budget_using = Budget.itogi_rashods(self)
    all_naklads = self.naklads.sum(:summ)
    plan_profit = budget_filling > 0 ? (Budget.itogi_raznica(self) / budget_filling) : 0
    state_units_size = self.get_metriks.select { |f| f.metrik_id == 1 }.inject(0){ |sum,x| sum + x.value }
    plan_revenue_on_state_unit = state_units_size > 0 ? (budget_filling / state_units_size) : 0
    plan_profit_on_state_unit  = state_units_size > 0 ? (plan_profit / state_units_size) : 0
    count_month = self.get_metriks.select { |f| f.metrik_id == 3 }.inject(0){ |sum, x| sum + x.value }
    fzp = self.get_metriks.select { |f| f.metrik_id == 4 }.inject(0){ |sum, x| sum + x.value }
    average_salary = fzp / count_month rescue 0

    json = {
      budget_filling: budget_filling,
      budget_using: budget_using,
      all_naklads: all_naklads,
      plan_marga: self.plan_marga,
      plan_profit: plan_profit,
      plan_revenue_on_state_unit: plan_revenue_on_state_unit,
      plan_profit_on_state_unit: plan_profit_on_state_unit,
      average_salary: average_salary
    }
  end

  # Проверка наличия в одной ветке
  def descendant(budget2)
    descendant = false
    return descendant if self.f_year != budget2.f_year

    if self.id < budget2.id
      budget_parent = budget2

      while (budget_parent != nil && budget_parent != self)
        if budget_parent.parent == self
          descendant = true
          break
        else
          budget_parent = budget_parent.parent
        end
      end
    end

    descendant
  end

  # клонирование в дочерний бюджет
  def clone_stat_zatrs_and_zatrats
    return if self.next_budget.nil?
    return if !self.next_budget.stat_zatr.empty?
    new_stat_zatr_ids = {}
    self.stat_zatr.each do |_stat_zatr|
      cloned_stat_zatr = _stat_zatr.dup
      cloned_stat_zatr.f_year    = self.next_budget.f_year
      cloned_stat_zatr.budget_id = self.next_budget.id
      cloned_stat_zatr.save
      new_stat_zatr_ids[_stat_zatr.id] = cloned_stat_zatr.id
    end

    Zatrat.where(f_year: self.f_year, stat_zatr_id: new_stat_zatr_ids.keys).all.each do |zatrat|
      cloned_zatrat = zatrat.dup
      cloned_zatrat.f_year       = self.next_budget.f_year
      cloned_zatrat.stat_zatr_id = new_stat_zatr_ids[cloned_zatrat.stat_zatr_id]
      cloned_zatrat.save
    end

  end


  # Проверка доступа
  def access_for(user)
    user.is_admin || ["editor", "reader"].include?(self.access?(user))
  end


  def access?(user)
    return "editor"  if self.user_id == user.id || user.is_admin

    # as owner
    self.ancestors.each do |budget|
      return "editor" if budget.user_id == user.id
    end

    # as reader or editor current budget
    user_role = UsersRole.find_by(user_id: user.id, budget_id: self.id)
    if user_role
      return "reader" if user_role.role == "reader"
      return "editor" if user_role.role == "editor"
    end

    # as nested editor
    UsersRole.where(user_id: user.id, role: "editor").each do |role|
      return "editor" if role.budget.is_or_is_ancestor_of?(self)
    end

    # as nested reader
    UsersRole.where(user_id: user.id, role: "reader").each do |role|
      return "reader" if role.budget.is_or_is_ancestor_of?(self)
    end

    return nil
  end

private

  def transfer_normativ
    unless self.normativ.nil?
      self.normativ.each do |normativ|
        normativ.budget_id = self.parent.id
        normativ.save
      end
    end
  end
end
