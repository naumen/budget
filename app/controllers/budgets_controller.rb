require_relative '../presenters/budget_presenter'
# require 'pi_charts'

class BudgetsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:set_change, :fot_delete_state_unit, :state_unit_salary, :report_access_users, :report_add_access_users, :report_del_access_users]

  include ActionView::Helpers::NumberHelper

  before_action :set_budget, only: [:show, :edit, :update, :destroy, :delete, :metrik_changes, :state_unit_salary]
  before_action :initialize_data, only: [:new, :show, :index, :create, :edit, :update]
  before_action :budget_types, only: [:new, :create, :edit, :update]

  before_action :access!, only: [:show, :edit]

  def load_doc
    @budget = Budget.find(params[:id])
    Document.store_file({file: params[:budget][:file]}, @budget)
    redirect_to "/budgets/#{@budget.id}/#docs"
  end

  def fot_edit
    @budget = Budget.find(params[:id])
    if request.post?
      # set_fot_delta_value(delta_value, user=nil, request_change=nil)
      @budget.set_fot_delta_value(params[:fot_delta_value].to_f, current_user)
      redirect_to "/budgets/#{@budget.id}/#stat_zatrs"
    end
  end

  def report_by_months
    @budget = Budget.find(params[:budget_id])

    if current_user.is_admin || current_user == @budget.owner
      # pass
    else
      render plain: "Ошибка доступа"
      return false
    end
    @budget_presenter = BudgetPresenter.new(@budget)
    @report = BudgetReportByMonthsPresenter.new(@budget, @budget_presenter)


    respond_to do |format|
      format.html do
        # pass
      end
      format.xlsx do
        @export = true
        filename = "report_by_months_#{@budget.id.to_s}.xls"
        headers['Content-Type']        = "application/vnd.ms-excel"
        headers['Content-Disposition'] = 'attachment; filename="'+filename+'"'
        render layout: "excel"
      end
    end
  end

  def report_access_users
    ret = BudgetParam.first.get_budgets_report_access_users.map{|u| { id: u.id, name: u.name}}
    render json: ret.to_json
  end

  def report_add_access_users
    user = User.find(params[:params][:user_id])
    BudgetParam.first.budgets_report_access_add_user(user)
    render json: ['ok']
  end

  def report_del_access_users
    user = User.find(params[:params][:user_id])
    BudgetParam.first.budgets_report_access_del_user(user)
    render json: ['ok']
  end


  # ajax
  def state_unit_salary
    ret = []
    state_unit = StateUnit.find(params[:state_unit_id])
    state_unit.salaries.each do |s|
      ret << {month: s.month.to_s, salary: s.summ}
    end
    render json: ret.to_json
  end

  def confirmations
    @hide_year_header = true
    if !current_user.access_to_all_confirmations?
      render plain: "нет доступа"
      return
    end
  end

  # todo move
  def users
    if current_user.is_admin?
      @users = User.order(:name).all.to_a.delete_if{|u| u.login == '' || u.name.starts_with?('.')}
    else
      render plain: "нет доступа"
      return
    end
  end

  def login_as
    if current_user.is_admin
      # pass
    elsif session['_parent_user_id'] && params[:id] == 'return'
      # pass
    else
      return
    end

    parent_user_id = nil
    if session['_parent_user_id']
      user = User.find(session['_parent_user_id'].to_i) if User.exists?(session['_parent_user_id'].to_i)
      session['_parent_user_id'] = nil
    else
      parent_user_id = current_user.id
      user = User.find(params[:id].to_i) if User.exists?(params[:id].to_i)
      session['_parent_user_id'] = parent_user_id if parent_user_id && user
    end

    if user
      log_out
      log_in(user)
    end
    redirect_to root_path
  end

  # шт. единицы отсутствующие в 2019 году
  # 2019 -> 2020
  def new_staff_items
    sql = """
      SELECT
        id, budget_id, staff_item_id
      FROM
        state_units
      WHERE
        f_year = 2019
        AND staff_item_id is not null
        AND staff_item_id not in (
          SELECT staff_item_id 
          FROM state_units 
          WHERE f_year = 2020
            AND staff_item_id is not null
        )
      ORDER BY budget_id
    """
    @result_rows = []
    rows = StateUnit.connection.select_all(sql)
    rows.each do |row|
      state_unit_id = row["id"]
      budget_id     = row["budget_id"]
      staff_item_id = row["staff_item_id"]
      budget = Budget.find(budget_id)
      @result_rows << [state_unit_id, budget_id, staff_item_id, budget]
    end
    @result_rows.sort_by!{|r| r[3].name}
  end

  def clone_state_unit
    state_unit = StateUnit.find(params[:id])
    state_unit.clone_state_unit
    redirect_to '/budget_new_staff_items'
  end

  # deprecated?
  def report2
  end


  def info_normativ_avg
    budget = Budget.find(params[:id])

    if budget.show_normativ_avg?
      # pass
    else
      render json: {}
      return
    end

    presenter = BudgetPresenter.new(budget)
    presenter.current_user = @current_user

    info = budget.info_normativ_avg(presenter.budget_info)

    render json: info.to_json
  end

  # deprecated
  def budget_report_row
    budget_id = params[:budget_id]
    ret = {}
    ret = {
      budget_name: "Бюджет #{budget_id}", budget_id: budget_id, cols:
      {
        "Планируемая рентабельность (%)": "col1.1",
        "Планируемая выручка на одного сотрудника (руб)": "col1.2",
      }
    }
    render json: ret
  end

  def report
    if current_user.is_admin? || BudgetParam.access_budget_report?(current_user)
      # pass
    else
      render plain: "ошибка доступа"
      return
    end
    @budget_ids = []
    @include_prev_year = params[:include_prev_year].to_i == 1
    # @f_year = [11, 12].include?(Time.now.month) ? (Time.now.year + 1) : Time.now.year
    @f_year = session[:f_year].to_i
    @budgets = Budget.where(f_year: @f_year).all.select{|b| b.budget_type && b.budget_type.name == "Сводный БН"}.sort_by{|b| b.name}

    if current_user.is_admin?
      # pass
    else
      @budgets.delete_if{|b| b.owner.id != current_user.id}
    end


    if request.post? && !params[:budget_ids].empty?
      @budget_ids = params[:budget_ids].map{|b_id| b_id.to_i}
      # { :budget_params, :rows }
      if @budget_ids.size > 0
        @report = Budget.get_report(@f_year, @budget_ids, @include_prev_year)
      end
    end
  end

  def metrik_changes
    @metrik_changes = @budget.get_metrik_changes
  end

  # fot

  def fot_salaries
    state_unit = StateUnit.find(params[:state_unit_id])

    salaries = {}
    if state_unit
      state_unit.salaries.each do |s|
        salaries[s.month] = s.summ
      end
    else
      (1..12).to_a.each do |m|
        salaries[m] = 0.0
      end
    end

    ret = {}
    ret["salaries"] = salaries
    ret["salaries_start"] = Salary.as_salaries_start(salaries)
    render json: ret
  end

  # получение списка бюджетов - текущий и вложенные
  def fot_budgets
    budget = Budget.find(params[:id])
    ret = []
    budget.self_and_descendants.each do |budget|
      ret << {
        id: budget.id,
        name: budget.name
      }
    end
    render json: ret
  end

  def fot_summary
    budget = Budget.find(params[:id])
    summary = {}
    summary['all'] = { cnt: 0, fzp: 0.0, free_cnt: 0, free_fzp: 0.0, closed_cnt: 0, closed_fzp: 0.0 }
    budget.self_and_descendants.each do |b|
      next if b.state_units.empty?
      b.state_units.each do |state_unit|
        location_id = state_unit.location_id
        if state_unit.user_id
          busy = true
        else
          busy = false
        end
        fzp = state_unit.fzp
        summary[location_id] ||= { cnt: 0, fzp: 0.0, free_cnt: 0, free_fzp: 0.0, closed_cnt: 0, closed_fzp: 0.0 }
        summary[location_id][:cnt] += 1
        summary[location_id][:fzp] += fzp
        summary['all'][:cnt] += 1
        summary['all'][:fzp] += fzp
        if state_unit.date_closed
          summary[location_id][:closed_cnt] += 1
          summary[location_id][:closed_fzp] += fzp
          summary['all'][:closed_cnt] += 1
          summary['all'][:closed_fzp] += fzp
        elsif !busy
          summary[location_id][:free_cnt] += 1
          summary[location_id][:free_fzp] += fzp
          summary['all'][:free_cnt] += 1
          summary['all'][:free_fzp] += fzp
        end
      end
    end
    ret = []
    ret << ["Локация", "Кол-во", "ФОТ", "в т.ч. вакантн.", "в т.ч. ФОТ вакантн.", "в т.ч. сокр.", "в т.ч. ФОТ сокр."]
    rows = Location.all.map{ |l| l.id}
    rows = ['all'] + rows
    rows.each do |r|
      next unless summary[r]
      row = []
      row[0] = r == 'all' ? 'Все' : "в т.ч. " + Location.find(r).name
      row[1] = summary[r][:cnt]
      row[2] = money summary[r][:fzp]
      row[3] = summary[r][:free_cnt]
      row[4] = money summary[r][:free_fzp]
      row[5] = summary[r][:closed_cnt]
      row[6] = money summary[r][:closed_fzp]
      ret << row
    end

    render json: ret
  end

  def fot_items
    budget = Budget.find(params[:id])

    ret = []
    budget.self_and_descendants.each do |budget|
      budget.state_units.each do |state_unit|
        is_busy = false
        employment_term = ''
        if state_unit.date_closed
          busy_info = '(сокращена)'
          is_busy = true
        elsif state_unit.staff_item_id
          if state_unit.user_id
            is_busy = true
            busy_info = User.find(state_unit.user_id).name.gsub('  ', ' ') rescue '-'
            employment_term = state_unit.user.employment_term_text if state_unit.user
          else
            busy_info = '(вакантна)'
          end
        else
          busy_info = '(вакантна, нет в HR)'
        end
        fzp = state_unit.fzp
        ret << {
          id: state_unit.id,
          staff_item_id: state_unit.staff_item_id,
          date_closed: state_unit.date_closed || '',
          cfo_name: (budget.cfo.name rescue ''),
          budget_id: budget.id,
          budget_name: budget.name,
          budget_state: budget.state,
          position: state_unit.position,
          division: state_unit.division,
          location: state_unit.location.name,
          location_id: state_unit.location_id,
          busy_info: busy_info,
          is_busy: is_busy,
          fot: fzp,
          fot_integer: fzp.to_i,
          employment_term: employment_term
        }
      end
    end
    render json: ret
  end

  # only 2020
  def set_change
    change_info = JSON.parse(params["params"]["info"])

    # редактирование или создание
    if change_info["id"]
      state_unit = StateUnit.find(change_info["id"])
    else
      state_unit = StateUnit.new
    end
    err_text = state_unit.set_change(change_info)

    if err_text.nil?
      ret = {result: "ok"}
    else
      ret = {result: "error", message: err_text}
    end
    render json: ret
  end

  def fot_delete_state_unit
    state_unit_id = params["params"]["state_unit_id"]
    state_unit = StateUnit.find(state_unit_id)
    if state_unit.delete
      ret = {result: "ok", state_unit_id: state_unit_id.to_i}
    else
      ret = {result: "error", message: "Ошибка при удалении"}
    end
    render json: ret
  end

  def fot2
    @budget = Budget.find(params[:id]) if params[:id]
    if @budget
      session[:f_year] = @budget.f_year
      if @budget.allow?("show_budget_fot_report", current_user)
        # pass
      else
        render plain: "Нет доступа"
        return
      end
    else
      if params[:f_year].to_i >= 2020
        session[:f_year] = params[:f_year].to_i
      else
        session[:f_year] = 2020 # TODO 
      end
    end
  end

  # index
  def fot
    @budget = Budget.find(params[:id]) if params[:id]
    if @budget
      session[:f_year] = @budget.f_year
    else
      if params[:f_year].to_i >= 2020
        session[:f_year] = params[:f_year].to_i
      else
        session[:f_year] = 2020 # TODO 
      end
      # WFT, wtf
      if current_user.is_admin?
        initialize_data(true)
        @accessable_budgets = @budgets
        @all_budgets = @accessable_budgets
      else
        index # budgets
      end
    end
  end

  # переходы между статусами бюджета:
  # - Черновик  "На утверждение"
  # - Утвержден "В черновик"
  # - Отклонен "В черновик"

  # согласование пользователем
  # если положительное согласование, и он последний
  # и есть вложенные бюджеты - тогда вывести подтверждение
  # на весь список бюджетов
  def sign
    @budget = Budget.find(params[:id])


    current_sign = BudgetSign.current_sign(@budget)

    if current_sign && current_sign.user_id == current_user.id
      result = params[:result].to_i

      # проверка на подтверждение всего списка
      # если утверждает и следуюего нет, и есть вложенные - то подтверждение
      if result == 0 || (result == 1 && current_sign.next_sign.nil?)
        if !@budget.descendants.empty? && params[:confirm_sign_all].nil?
          redirect_to budget_path(@budget, confirm_sign_all: params[:result], anchor: "confirmation")
          return
        end
      end

      current_sign.result = result
      current_sign.result_date = Time.now
      current_sign.save

      if result == 0
        # отклонение --------------------------------------------------
        success_text = 'Бюджет отклонен'
        @budget.state = 'Отклонен'
        @budget.save
        BudgetHistory.log(@budget.id, current_user.id, @budget.state)

        # при отклонении - обнуляем все is_current_attempt
        BudgetSign.where(budget: @budget).update_all(is_current_attempt: false)

        # уведомление владельцу
        current_sign.send_email_cancelled

        # надо переводить все вложенные бюджеты
        # выполнить переход для всех вложенных бюджетов
        # но пропускаем те бюджеты что Утверждены
        @budget.descendants.each do |b|
          next if b.state == 'Утвержден'
          b.state = @budget.state
          b.save
          BudgetHistory.log(b.id, current_user.id, b.state)
        end
      else
        # согласован +++++++++++++++++++++++++++++++++++++++++++++++++++++
        success_text = 'Согласование выполнено'
        if BudgetSign.is_all_confirmed?(@budget)
          # если все согласовали - то переводим бюджет в "Утвержден"
          @budget.state = 'Утвержден'
          @budget.save
          BudgetHistory.log(@budget.id, current_user.id, @budget.state)

          # уведомление владельцу
          current_sign.send_email_confirmed

          # надо переводить в статус Утвержден все вложенные бюджеты
          # выполнить переход для всех вложенных бюджетов
          # пропускаем те - кто уже в статусе "Утвержден"
          @budget.descendants.each do |b|
            next if b.state == 'Утвержден'
            b.state = @budget.state
            b.save
            BudgetHistory.log(b.id, current_user.id, b.state)
          end
          success_text += ' Бюджет утвержден'
        else
          # если есть следующий в цепочке согласования, то
          # посылается на согласование следующему
          current_sign.next_sign.send_email_confirmation
        end
      end
        redirect_to @budget, success: success_text
    else
      redirect_to @budget, danger: 'Согласование не было выполнено'
    end
  end

  # изменение статуса бюджета, может выполнить владелец бюджета или администратор
  # переходы:
  # - На утверждение (из статуса Черновик) to_confirm
  # - В черновик (из статуса Отклонен) to_draft
  # При переходе "На утверждение":
  # - формируется список согласователей
  #   если переход делает админ - то в согласователи включается владелец бюджета и
  # владелец родительского бюджета
  #   если переход делает владелец бюджета - то только родительский владелец
  def set_state
    @budget = Budget.find(params[:id])
    # todo move to model

    # Если есть вложенные бюджеты то надо подтверждение от пользователя
    # что эти бюджеты будут переведены так же в новый статус
    if !@budget.descendants.empty? && params[:all].nil?
      redirect_to budget_path(@budget, confirm_set_state: params[:state])
      return
    end

    state = 'На утверждении' if params[:state] == 'to_confirm'
#    state = 'Утвержден' if params[:state] == 'to_confirm'
    state = 'Черновик' if params[:state] == 'to_draft'

    @budget.state = state

    if @budget.save
      if @budget.state == 'На утверждении'
        # формирование списка согласователей
        @budget.init_sign_users(current_user)
        # посылаем уведомление первому согласователю
        current_sign = BudgetSign.current_sign(@budget)
        current_sign.send_email_confirmation
      end
      BudgetHistory.log(@budget.id, current_user.id, @budget.state)

      # выполнить переход для всех вложенных бюджетов
      # Если делаем переход "На утверждении"
      # то пропускаем бюджет что в статусе "Утвержден"
      # Если переходим в "Черновик", то переводятся
      # все вложенные бюджеты
      @budget.descendants.each do |b|
        next if state == 'На утверждении' && b.state == 'Утвержден'
        b.state = state
        b.save
        BudgetHistory.log(b.id, current_user.id, b.state)
      end
      redirect_to @budget, success: 'Переход был выполнен'
    else
      redirect_to @budget, danger: 'Ошибка при переходе'
    end

  end

  def clone_budget_to_next_year
    # todo
    @budget = Budget.find(params[:budget_id])
    if @budget.next_budget
      redirect_to @budget, danger: 'Бюджет уже существует на следующий год'
    else
      if @budget.clone_to_next_year
        redirect_to @budget, success: 'Бюджет склонирован на следующий год'
      else
        redirect_to @budget, danger: 'Ошибка при клонировании'
      end
    end
  end

  def graph
    if current_user.is_admin? || current_user.any_budget_owner?
      @_year = session[:f_year]
      render layout: 'graph'
    else
      render plain: '-'
    end
  end

  def info
    require "json"
    info = {}
    @_year = params[:_f_year]

    nakl = Budget.where( name: "Накладные расходы",  f_year: @_year ).all
    if nakl.size == 1
      nakl = nakl[0]
    else
      render :plain=>'не найден накладной бюджет'
      return
    end

    @_norm_budgets = _get_norm_budgets(@_year.to_i)
    @_prev_norm_budgets = _get_norm_budgets(@_year.to_i - 1)

    @_prev_budgets = {}; Budget.where( f_year: @_year.to_i - 1 ).all.map{|b| @_prev_budgets[b.id] = b}
    _info = {}
    _info = get_info(nakl, _info)

    str = JSON.generate(_info)
    response.headers['Content-Type'] = 'application/vnd.api+json'
    render :plain=>str
  end

  # todo move to model
  # { budget_id => norm | '...' }
  def _get_norm_budgets(year)
    ret = {}
    Normativ.where( f_year: year ).all.each do |norm|
      if ret[norm.budget_id]
        ret[norm.budget_id] = '...'
      else
        ret[norm.budget_id] = norm.norm
      end
    end
    ret
  end

  # todo move to model
  def get_info(b, _info)
    # todo
    _prev_budget = @_prev_budgets[b.id - 10000] rescue nil
    _info[:name] = "#{b.name}"
    _info[:name] += "\nРасх.: #{number_to_currency(b.itogo_usage.to_i, :unit => "", :precision => 0)}"
    if _prev_budget
      nakl_budget_delta = b.itogo_usage.to_f - _prev_budget.itogo_usage.to_f
      _perc = nakl_budget_delta/_prev_budget.itogo_usage.to_f*100.0 if _prev_budget.itogo_usage.to_f != 0.0
      if _perc
        nakl_perc = "%0.2f%" % _perc
        sign = '+' if nakl_budget_delta > 0.0
        _info[:name] += " (#{sign}#{nakl_perc})"
        if _perc > 10.0
          _info[:name] += '{RED}'
        elsif _perc < 0.0
          _info[:name] += '{GREEN}'
        end
      end
    end

    # normativs
    _norm = @_norm_budgets[b.id] rescue nil
    _prev_norm = @_prev_norm_budgets[b.id - 10000] rescue nil
    _info[:name] += "\nНорм.: "
    if _norm && _norm == '...'
      _info[:name] += 'несколько'
    elsif _norm
      _info[:name] += number_to_currency(
        _norm,
        :unit => "",
        :precision => _norm < 1.0 ? 4: 0
      )

      if _prev_norm && _prev_norm != '...'
        _norm_delta = _norm.to_f - _prev_norm.to_f
        _norm_perc  = _norm_delta/_prev_norm.to_f*100.0 if _prev_norm.to_f != 0.0
        if _norm_perc
          norm_perc = "%0.2f%" % _norm_perc
          sign = '+' if _norm_delta > 0.0
          _info[:name] += " (#{sign}#{norm_perc})"
        end
      end
    end

    _info[:name] += "\n#{b.id}"

    if b.children.size > 0
      _info[:children] = []
      b.children.each do |_b|
        _info[:children] << get_info(_b, {})
      end
    end
    return _info
  end



  def index
    session[:f_year] = params[:f_year].to_i if params[:f_year]


    is_backup_stend = Rails.env.development? && request.port == 4010

    f_year = session[:f_year]

    top_budget = Budget.roots.where(f_year: f_year).first
    if top_budget.nil?
      session[:f_year] = 2023
      f_year = 2023
      top_budget = Budget.roots.where(f_year: f_year).first
    end

    @prev_year_link = nil
    @next_year_link = nil

if false
    if f_year >= 2019
      @prev_year_link = "?f_year=#{f_year-1}"
    end

    if f_year < 2021
      @next_year_link = "?f_year=#{f_year+1}"
    end

    if is_backup_stend && f_year == 2020
      @next_year_link = nil
    end
end


    @all_budgets = top_budget.self_and_descendants
    if current_user.is_admin
      @accessable_budgets = @all_budgets
    else
      @accessable_budgets = current_user.available_budgets(f_year, true) # include reader

      @child_budgets_columns = {
        # name:         "Наименование",
        state:        "Статус",
        in:           "Наполнение",
        out:          "Использование",
        plan_marga:   "Плановая маржа",
        delta:        "(-дефиц)/профиц",
      }

      root_budget = Budget.roots.find_by(f_year: f_year)
      @budget_presenter = BudgetPresenter.new(root_budget, true)
    end
  end


  def show
    if @budget.archived
      render "archived"
      return
    end

    @presenter = BudgetPresenter.new(@budget, nil, params[:filter_metrik])
    @presenter.current_user = @current_user

    # for year's header links
    if @budget.prev_budget_id
      prev_budget = Budget.find(@budget.prev_budget_id)
      @prev_year_link = budget_path(prev_budget)
    end
    if @budget.next_budget_id
      next_budget = Budget.find(@budget.next_budget_id)
      @next_year_link = budget_path(next_budget)
    end

    render "metrik_details" if params[:metrik_details]
  end

  def _show
    @last_open_budget = session['last_busget_id'] = @budget.id
    get_breadcrumb

    # @sales = Sale.where('budget_id=?', @budget.id)
    @sales = @budget.sale
    # @stat_zatrs = StatZatr.where('budget_id=?', @budget.id)


    @zatrats_sum = 0
    @budget.stat_zatr.each do |stat_zatr|
      @zatrats_sum += stat_zatr.zatrats.sum(:summ)
    end

    @data = Budget.budget_empty?(@budget)
    @def_prof = Budget.def_prof(@budget)
    #@access_edit = @budget.access?(current_user)
    @year_spin = true
    @budget_setting = BudgetSetting.where(budget_setting_type_id: @budget.type_budget.id)

    @budget_metriks = @budget.get_metriks
    @budget_state_unit_size = @budget_metriks.select { |f| f["metrik_id"] < 2 }.inject(0){ |sum,x| sum + x.value }

    #@budget_statistics = @budget.generate_statistics
    @budget_statistics = []
  end

  def new
    @budget = Budget.new
    @budget.parent = Budget.find(params[:budget_id]) if params[:budget_id]
    @budgets = @budgets.uniq if @budgets.length > 1
  end

  def create
#     @last_budget_in_year = Budget.where(f_year: session[:f_year]).last
# .merge({id: (@last_budget_in_year.id + 1)}))
    @budget = Budget.new(budget_params)
    if @budget.save
      if params[:budget][:parent_id]
        @parent_budget = Budget.find(params[:budget][:parent_id])
        @budget.move_to_child_of(@parent_budget)
      end
      redirect_to @budget, success: 'Бюджет успешно создан'
    else
      flash.now[:danger] = 'Бюджет не создан'
      render :new
    end
  end

  def edit
    if @budget.parent
      @budgets_type = BudgetType.order(:name).all
    end
  end

  def update
    # some bug in edit root budget
    if @budget.parent.nil?
      _budget_params = budget_params.to_h
      _budget_params[:parent_id] = nil if _budget_params[:parent_id].to_i == 0
      if @budget.update_columns(_budget_params)
        redirect_to @budget, success: 'Бюджет успешно обновлен'
      else
        flash.now[:danger] = 'Бюджет не обновлен'
        render :edit
      end
    else
      if @budget.update(budget_params)
        redirect_to @budget, success: 'Бюджет успешно обновлен'
      else
        flash.now[:danger] = 'Бюджет не обновлен'
        render :edit
      end
    end
  end

  def destroy
    if @budget.destroy
      redirect_to @budget.parent
    end
  end

  def delete
    if @budget.delete(current_user)
      flash.now[:success] = 'Бюджет заархивирован'
      redirect_to @budget.parent
    else
      flash.now[:danger] = 'Бюджет не был удален'
      redirect_to @budget
    end
  end

  def settings
    @budgets_type                 = BudgetType.all
    @budget_settings_filling      = SettingParam.where( setting_type: 1 )
    @budget_settings_using        = SettingParam.where( setting_type: 2 )
    @budget_settings_budget_type  = SettingParam.where( setting_type: 3 )

    @budget_setting = BudgetSetting.all
  end

  def settings_save
    @budget_setting = BudgetSetting.all

    @budgets_type                 = BudgetType.all
    @budget_settings_filling      = SettingParam.where( setting_type: 1 )
    @budget_settings_using        = SettingParam.where( setting_type: 2 )
    @budget_settings_budget_type  = SettingParam.where( setting_type: 3 )


    budget_settings_array = []
    BudgetSetting.delete_all
    unless params["settings"].nil?
      params["settings"].each do |budget_setting_type_id, value|
        value.each do |settings_params_id, value|
          budget_settings_array.push({ budget_setting_type_id: budget_setting_type_id, settings_params_id: settings_params_id })
        end
      end
    end

    if BudgetSetting.create(budget_settings_array)
      render :settings, danger: 'Настройки не сохранились'
    else
      redirect_to settings_path, success: 'Настройки сохранились'
      flash.now[:success] = 'Настройки сохранились'
    end
  end

  def budget_setting
    @answer_json = []

    if params[:budget_id].to_i == 0
      BudgetType.all.each do |budget_type|
        @answer_json.push([ budget_type.id, budget_type.name ])
      end
    else
      @budget = Budget.find(params[:budget_id].to_i)
      @budget_setting = BudgetSetting.where(budget_setting_type_id: @budget.type_budget.id)
      @budget_setting.each do |budget_setting|
        if budget_setting.setting_params.setting_type == 3
          @answer_json.push([ budget_setting.setting_params.budget_type.id, budget_setting.setting_params.budget_type.name ])
        end
      end
    end

    render json: @answer_json
  end

  private

  def budget_types
    params1 = params[:budget_id] if params[:budget_id]
    params2 = @budget.parent_id if @budget
    params3 = params[:budget][:parent_id] if params[:budget]

    if (params1 || params2 || params3) && @budget && !@budget.parent.nil?
      budget = Budget.find(params[:budget_id]) if params[:budget_id]
      budget = Budget.find(params[:budget][:parent_id]) if params[:budget]
      budget = @budget.parent if @budget
      @budgets_type = []
#       budget.type_budget.budget_setting.each do |setting|
#         if setting.setting_params.setting_type == 3
#           @budgets_type.push(setting.setting_params.budget_type)
#         end
#       end
    end
  end

  def access!
    @access = false

    if @budget.access_for(current_user)
      if @budget.f_year != session[:f_year]
        session[:f_year] = @budget.f_year
      end
      @access = true
    end

    redirect_to budgets_path, danger: 'Нет доступа к бюджету' if !@access
  end

  def set_budget
    @budget = Budget.find(params[:id]) if params[:id]
    session[:f_year] = @budget.f_year
  end

  def initialize_data(as_tree=false)
#     if !logged_in? || @current_user.nil?
#       session[:previous_url] = request.fullpath
#       redirect_to login_path
#     end
    if @current_user.is_admin
      budgets_as_tree = ['new', 'edit', 'update'].include?(params[:action])
      if budgets_as_tree || as_tree
        root = if session[:f_year].to_i == 2023
                  Budget.find(90001)
               end
        @budgets =[]
        Budget.each_with_level(root.self_and_descendants) do |b|
          @budgets << b
        end
      else
        @budgets = Budget.where(f_year: session[:f_year])
      end
    else
      @budgets = @current_user.give_available_budgets(session[:f_year]) unless @current_user.nil?
    end

    @budgets = @budgets.to_a.delete_if{|b| b.archived}

    @budgets_type = BudgetType.all
    @cfos = Cfo.where(archive_date: nil).sorted.to_a.delete_if{|cfo| cfo.name.downcase.index("закрыт")}
    @cfo_type = SprCfoType.all
    @users = User.all.to_a.delete_if{ |u| u.login.to_s.empty? }.sort_by{|u| u.l_name}
  end

  def budget_params
    params.require(:budget).permit(:name, :target, :parent_id, :f_year, :budget_type_id, :currency, :cfo_id, :cfo_type_id, :user_id, :budget_create, :state, :plan_marga, :plan_invest_marga, :nepredv)
  end
end
