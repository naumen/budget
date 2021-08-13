class BudgetPresenter

  attr_accessor :child_budgets_columns, :state_units_columns, :budget_calculator, :current_user
  attr_writer :is_for_report

  def initialize(budget, calculate_all_budgets_itogo=nil, filter_metrik=nil)
    @budget = budget
    @current_user = nil

    # флаг обозначает что презентер выполняется для отображения данных для отчёта "/budgets/report"
    @is_for_report = false

    @budget_metrik_calculator = BudgetMetrikCalculator.new(@budget.f_year)

    # restore from cashe
    #BudgetMetrik.restore_calculated_metriks(@budget_metrik_calculator)
    @budget_metrik_calculator.calculate

    @budget_metriks = @budget_metrik_calculator.budget_metriks
    # метрики что не включены
    @budget_out_metriks = @budget_metrik_calculator.budget_out_metriks

    # ActiveRecord::Base.logger = Logger.new(STDOUT)

    @budget_calculator = CompanyBudgetCalculator.new(@budget_metrik_calculator, @budget, calculate_all_budgets_itogo)
    @budget_calculator.calculate_company_budget

    @company_budget = @budget_calculator.company_budget
    @filter_metrik = filter_metrik

    init_child_budgets_columns
    init_state_units_columns
  end

  # инвест проекты
  # invest projects
  def budget_invest_projects
    rows = []
    itogo = {}
    itogo[:summ] = 0.0
    InvestmentProject.where(from_budget: @budget).or(InvestmentProject.where(to_budget: @budget)).all.each do |r|
      rows << r
      itogo[:summ] += r.summ.to_f
    end
    [rows, itogo.to_ostruct]
  end

  # инвест займы
  # invest loans
  def budget_invest_loans
    rows = []
    itogo = {}
    itogo[:summ] = 0.0
    InvestLoan.where(use_budget: @budget).or(InvestLoan.where(credit_budget: @budget)).all.each do |r|
      rows << r
      itogo[:summ] += r.summ.to_f
    end
    [rows, itogo.to_ostruct]
  end

  # выплаты
  # TODO 2year ago
  def budget_invest_loan_payments
    rows = []
    itogo = {}
    itogo[:summ] = 0.0
    RepaymentLoan.where(fin_year: @budget.f_year).all.each do |r|
      if (@budget.prev_budget && @budget.prev_budget == r.invest_loan.credit_budget)
        rows << r
        itogo[:summ] += r.summ.to_f
      end
    end
    [rows, itogo.to_ostruct]    
  end


  # -------------- INFO
  def budget_info
    # ostruct
    ret = @budget_calculator.budgets_info[@budget.id]

    # in
    ret[:sales_itogo] = ret.in.own.sales.to_f + ret.in.sub.sales.to_f

    # itogo
    ret[:plan_marga]  = @budget.plan_marga
    ret[:marga_delta] = (ret.in.itogo.to_f - ret.out.itogo.to_f) - @budget.plan_marga.to_f - ret.in.nds.to_f
    ret[:diff_between_in_and_out] = ret.in.itogo - ret.out.itogo - ret.in.nds.to_f
    ret
  end


  # Сравнение с прошлым периодом
  # прирост бюджета
  def budget_diff
    ret = nil
    if @budget.prev_budget
      prev_budget_itogo_out = @budget.prev_budget.itogo_usage
      if prev_budget_itogo_out.to_f > 0.0
        ret = {}
        delta = budget_info.out.itogo - prev_budget_itogo_out
        perc  = "%0.2f%" % (delta / prev_budget_itogo_out * 100.0)
        ret[:delta]         = delta
        ret[:delta_percent] = perc
      end
    end
    ret
  end

  # прирост норматива
  def normativ_diff
    ret = nil
    if normativ = @budget.normativs.select{|n| n.metrik_id != 11}.first
      prev_normativ = normativ.normativ_in_prev_year
      if prev_normativ
        ret = {}
        delta = normativ.norm.to_f - prev_normativ.norm.to_f
        perc  = "%0.2f%" % (delta / prev_normativ.norm.to_f * 100.0)
        ret[:delta]         = delta
        ret[:delta_percent] = perc
      end
    end
    ret
  end


  # -------------- PARAMETERS
  def budget_parameters(for_report=false)
    ret = [] # title, name, value, type { 'perc' | 'money' }

    _budget_info = budget_info


    # TODO
    all_state_unit_cnt = @budget_metriks[@budget.id][:all_state_units] rescue 0
    all_state_unit_cnt = all_state_unit_cnt.to_i
    sales_itogo        = _budget_info.sales_itogo

    all_state_units_m_cnt = @budget_metriks[@budget.id][:all_state_units_m] rescue 0
    all_state_units_m_cnt = all_state_units_m_cnt.to_i

    # Для Сводный СН -- не отображать
    unless @budget.budget_type_id == 11
      #
      name = "Планируемая рентабельность"
      diff_between_in_and_out = _budget_info.diff_between_in_and_out

      title =  "Разница между доходами и расходами / Объем продаж * 100"
      title += " = (#{money(diff_between_in_and_out)} / #{money(sales_itogo)} * 100)"
      value = diff_between_in_and_out / sales_itogo * 100
      ret << {
        title:  title,
        name:   name,
        value:  value,
        type:   'perc'
      }

      name = "Планируемая выручка на одного сотрудника"

      if all_state_unit_cnt > 0
        title = "Объем продаж / Общее кол-во штатных единиц"
        title += " = (#{money(sales_itogo)} / #{all_state_unit_cnt})"
        value = sales_itogo / all_state_unit_cnt
        ret << {
          title: title,
          name: name,
          value: value,
          type: 'money'
        }
      end

      #
      name = "Планируемая доходность на одного сотрудника"

      if all_state_unit_cnt > 0
        title = "Разница между доходами и расходами / Общее кол-во штатных единиц"
        title += " = (#{money(diff_between_in_and_out)} / #{all_state_unit_cnt})"
        value = diff_between_in_and_out / all_state_unit_cnt
        ret << {
          title: title,
          name: name,
          value: value,
          type: 'money'
        }
      end
    end

    #
    name = "Среднемесячная ЗП"
    budget_fzp = _budget_info.out.own.salary.to_f + _budget_info.out.sub.salary.to_f
    title = "ФЗП Бюджета / Общее кол-во ШЕ помесячно"
    title += " = (#{money(budget_fzp)} / #{all_state_units_m_cnt})"
    value = 0
    unless all_state_units_m_cnt.to_i == 0
      value = budget_fzp / all_state_units_m_cnt
    end
    ret << {
      title: title,
      name: name,
      value: value,
      type: 'money'
    }

    name = "Выручка на рубль з/п"
    budget_fzp_and_premiums = @budget_metriks[@budget.id][:fzp_and_premii] rescue 0.0
    title = "Объем продажи / ФЗП и Премии Бюджета"
    title += " = (#{money(sales_itogo)} / #{money(budget_fzp_and_premiums)})"
    value = 0
    unless budget_fzp_and_premiums.to_f == 0.0
      value = sales_itogo.to_f / budget_fzp_and_premiums.to_f
    end
    ret << {
      title: title,
      name: name,
      value: value,
      type: 'float'
    }

    if @is_for_report
      ret << {
        title: "Продажи #{@budget.f_year} г.",
        name: "Продажи",
        value: _budget_info.sales_itogo,
        type: 'money'
      }
      ret << {
        title: "Расходы #{@budget.f_year} г.",
        name: "Расходы",
        value: _budget_info.out.itogo,
        type: 'money'
      }
    end

    ret.map{|item| item.to_ostruct}
  end

  # -------------- NAKLADN
  # 1	Продажи
  # 2	ИТ
  # 3	HR
  # 4	ОФИС
  # 5	Развитие

  def nakladn_groups
    ret = []
    Naklad.nakladn_groups.each do |code, id_and_name|
      ret << [code, id_and_name[1] ]
    end
    ret
  end

  def _filter_nakladn_by_group_code(nakladn_details_all, group_code)
    ret = []
    normativ_f_type_id = nil
    Naklad.nakladn_groups.each do |code, id_and_name|
      if code == group_code
        normativ_f_type_id = id_and_name[0]
        break
      end
    end

    nakladn_details_all.each do |nakladn|
      if group_code == 'by_weight'
        ret << nakladn if nakladn[:normativ_f_type].nil? && ['by_weight', 'equally'].include?(nakladn[:metrik_code])
      elsif group_code == 'base'
        ret << nakladn if nakladn[:normativ_f_type].nil? && !['by_weight', 'equally'].include?(nakladn[:metrik_code])
      else
        ret << nakladn if nakladn[:normativ_f_type] == normativ_f_type_id
      end
    end
    ret
  end

  def nakladn_by_group(group_code)
    # filter
    nakladn_details_all = @company_budget[@budget.id][:out][:nakladn_details] rescue []
    nakladn_details = _filter_nakladn_by_group_code(nakladn_details_all, group_code)

    rows = []
    itogo = { summ: 0.0 }


    nakladn_details.each do |nakladn|
      summ = nakladn[:nakladn_value]

      row = {}
      row[:normativ_f_type] = nakladn[:normativ_f_type]
      row[:normativ_name]   = nakladn[:normativ_name]
      row[:metrik_name]     = nakladn[:metrik_name]


      row[:metrik_value] = if row[:metrik_name] == 'По весу'
                             nakladn[:nakladn_weight]
                           else
                             nakladn[:metrik_value]
                           end
      row[:norm] = nakladn[:norm]
      row[:summ] = summ
      rows << row.to_ostruct

      itogo[:summ] += summ
    end
    rows.sort_by!{|r| r[:normativ_name]}
    [rows, itogo.to_ostruct]
  end

  # -------------- ZATRATAS
  def zatratas
    rows = []

    sql = """
      SELECT
        stat_zatrs.id,
        stat_zatrs.budget_id,
        stat_zatrs.name,
        stat_zatrs.spr_stat_zatrs_id,
        stat_zatrs.f_year,
        SUM(zatrats.summ) as summa,
        COUNT(*) as cnt
      FROM
        stat_zatrs,
        zatrats
      WHERE
        stat_zatrs.budget_id = #{@budget.id}
        AND zatrats.stat_zatr_id = stat_zatrs.id
      GROUP BY
        stat_zatrs.budget_id,
        zatrats.stat_zatr_id
    """
    spr_fot  = SprStatZatr.get_fot_item
    Zatrat.connection.select_all(sql).each do |r|
      z_id = r['id']
      row = {}
      row[:id]    = r['id']
      row[:name]  = r['name']
      row[:summa] = r['summa']
      row[:spr_stat_zatrs] = SprStatZatr.find(r['spr_stat_zatrs_id']).name rescue '-'
      row[:year] = r['f_year']
      row[:cnt]  = r['cnt']
      row[:is_fot] = r['spr_stat_zatrs_id'].to_i == spr_fot.id
      rows << row.to_ostruct
    end

    # return rows if rows.empty?

    # TODO
    stat_zatr_ids = rows.map{ |r| r.id }
    addon = ''
    if !stat_zatr_ids.empty?
      addon = "stat_zatrs.id not in (#{stat_zatr_ids.join(',')}) AND "
    end
    sql_empty = """
      SELECT
        stat_zatrs.id,
        stat_zatrs.budget_id,
        stat_zatrs.name,
        stat_zatrs.spr_stat_zatrs_id,
        stat_zatrs.f_year
      FROM
        stat_zatrs
      WHERE
        #{addon} stat_zatrs.budget_id = #{@budget.id}
    """
    Zatrat.connection.select_all(sql_empty).each do |r|
      z_id = r['id']
      row = {}
      row[:id]    = r['id']
      row[:name]  = r['name']
      row[:summa] = 0.0
      row[:spr_stat_zatrs] = SprStatZatr.find(r['spr_stat_zatrs_id']).name rescue '-'
      row[:year]  = r['f_year']
      row[:cnt]   = 0
      rows << row.to_ostruct
    end

    rows.sort_by{|z| z.name}
  end

  # -------------- SALES
  def sales
    rows = []
    itogo = { summ: 0.0 }
    @budget.sales.each do |sale|
      row = {}
      row[:id]      = sale.id
      row[:name]    = sale.name
      row[:quarter] = sale.quarter
      row[:summ]    = sale.summ
      row[:f_year]  = sale.f_year
      row[:user]    = sale.owner.name rescue ''
      row[:cfo]     = sale.budget.cfo.name rescue ''
      row[:sale_channel] = sale.sale_channel.name rescue ''
      rows << row.to_ostruct

      itogo[:summ] += sale.summ
    end
    [rows, itogo.to_ostruct]
  end

  # -------------- NORMATIVS
  def normativs
    rows = []
    @budget.normativs.each do |normativ|
      normativ_info = normativ.info
      row = {}
      row[:id] = normativ.id
      row[:name] = normativ.name
      row[:description] = normativ.description
      row[:norm] = normativ.norm
      row[:metrika] = normativ.metrik.name
      row[:nakladn] = normativ.naklads.size
      row[:summa] = normativ_info[:summa] rescue 0.0
      row[:metrik_value] = normativ_info[:metrik_itogo] rescue nil

      rows << row
    end
    return rows
  end

  # -------------- METRIKS
  def metriks
    rows = []
    this_budget_metriks = @budget_metriks[@budget.id] || {}

    this_budget_out_metriks = @budget_out_metriks[@budget.id] || {}

    @metriks = Metrik.all
    this_budget_metriks.each do |metrik_code, val|
      izm = _get_metrik_izm(metrik_code)
      as_money = ['fzp_by_location', 'fzp_by_location_msk', 'fzp_by_location_twr', 'fzp_by_location_chel',
                  'fzp_by_location_sev', 'fzp_by_location_spb', 'fzp_by_location_kdr', 'fzp', 
                  'sales_total','by_weight', 'equally', 'premii', 'fzp_and_premii', 'direct_costs'].include?(metrik_code.to_s)
      rows << {
        name: metrik_code_to_name(metrik_code),
        code: metrik_code,
        val: val,
        izm: izm,
        invest: (this_budget_out_metriks[:invest][metrik_code] rescue nil),
        sub: (this_budget_out_metriks[:sub][metrik_code] rescue nil),
        as_money: as_money} if val.to_f > 0.0
    end
    rows.sort_by{|r| r[:name]}
  end

  def _get_metrik_izm(metrik_code)
    if ['premii', 'fzp_and_premii', 'fzp_by_location', 'fzp_by_location_msk', 'fzp_by_location_spb',
        'fzp_by_location_kdr', 'fzp_by_location_twr', 'fzp_by_location_chel', 'fzp_by_location_sev', 
        'fzp','sales_total', 'sales_total'].include?(metrik_code.to_s)
      "руб."
    elsif metrik_code=='by_weight' || metrik_code=='equally'
      "вес."
    else
      "шт."
    end
  end

  # -------------- CHILD BUDGETS
  def child_budgets
    rows = []
    itogo = {}
    _itogo_fields = [:in, :out, :plan_marga, :delta]
    # init itogo
    _itogo_fields.each do |f|
      itogo[f] = 0.0
    end
    @budget.children.sort_by{|b| b.name}.each do |budget|
      next if budget.archived
      row = self.budget_row(budget)
      rows << row
      _itogo_fields.each do |f|
        itogo[f] += row[f].to_f
      end
    end
    [rows, itogo]
  end

  def budget_row(budget)
    budget_info = @budget_calculator.budgets_info[budget.id]
    return nil if budget_info.nil?
    row = {
      id:   budget.id,
      name: budget.name,
      state: budget.state,
      cfo_name: (budget.cfo.name rescue ''),
      budget_type: (budget.budget_type.name rescue ''),
      owner: (budget.owner.name rescue '-'),
      in:   budget_info.in.itogo,
      out:  budget_info.out.itogo,
      plan_marga: budget.plan_marga,
      delta: budget_info.in.itogo - budget_info.out.itogo - budget.plan_marga.to_f - budget_info.in.nds.to_f
    }
    row
  end

  # -------------- STATE UNITS
  def state_units
    rows = []

    state_units = []
    state_units += @budget.busy_state_units.sort_by{|st| st.user.name rescue '.'}
    state_units += @budget.vacant_state_units

    itogo = 0.0
    state_units.each do |state_unit|
      itogo += state_unit.fzp
      # outsource
      # временный подрядчик
      user_employment_term = ''
      if state_unit.user
        user_employment_term = state_unit.user.employment_term_text
      end
      rows << {
        id:   state_unit.id,
        staff_item_id:   state_unit.staff_item_id,
        date_closed: state_unit.date_closed,
        fio: state_unit.fio,
        user_id: state_unit.user_id,
        fzp: state_unit.fzp,
        division: state_unit.division,
        position: state_unit.position,
        location: state_unit.location.name,
        employment_term: user_employment_term
      }
    end

    itogo = {
      fio: nil,
      fzp: itogo,
      division: nil,
      position: nil,
      location: nil
    }

    [rows, itogo]
  end

  # детализация метрик бюджета
  # { columns: , budget_rows: , metrik_itogo: }
  def metrik_details
    columns = []
    columns << "Бюджет"
    columns << "Тип"

    self_and_descendants = @budget.self_and_descendants
    budget_ids = self_and_descendants.map{|b| b.id}

    # { b_id: {metrik_code: ..., ...}, ...}
    budget_metriks = @budget_metrik_calculator.own_budget_metriks

    metriks = []
    budget_ids.each do |b_id|
      if budget_metriks.has_key?(b_id)
        budget_metriks[b_id].keys.each do |metrik_code|
          metriks << metrik_code
        end
      end
    end
    metriks.uniq!

    col_metriks = metriks.sort_by{|m| metrik_code_to_name(m)}
    if @filter_metrik
      col_metriks.delete_if{ |m| m.to_s != @filter_metrik.to_s}
    end

    columns += col_metriks.map{|m| metrik_code_to_name(m)}

    metrik_itogo = {}
    rows = []
    self_and_descendants.each do |budget|
      row = {}
      row[:budget] = {}
      row[:budget][:id] = budget.id
      row[:budget][:name] = budget.name
      row[:budget][:level] = budget.level - @budget.level
      row[:budget][:budget_type] = { name: (budget.budget_type.name rescue '-')}
      row[:values] = []
      col_metriks.each do |metrik_code|
        next if @filter_metrik && @filter_metrik.to_s != metrik_code.to_s
        metrik_itogo[metrik_code] ||= 0.0
        value = budget_metriks[budget.id][metrik_code] rescue 0.0
        if value != 0.0
          row[:values] << value
        else
          row[:values] << ''
        end
        metrik_itogo[metrik_code] += value.to_f
      end

      rows << row.to_ostruct
    end

    { columns: columns, budget_rows: rows, metrik_itogo: metrik_itogo }
  end

  def metrik_code_to_name(metrik_code)
    Metrik.find_by_code(metrik_code).name rescue "error metrik code #{metrik_code}"
  end

  private

  def init_child_budgets_columns
    @child_budgets_columns = {
      name:         "Наименование",
      state:        "Статус",
      budget_type:  "Тип",
      cfo_name:     "ЦФО",
      owner:        "Владелец",
      in:           "Наполнение",
      out:          "Использование",
      plan_marga:   "Плановая маржа",
      delta:        "(-дефиц)/профиц",
    }
  end

  def init_state_units_columns
    @state_units_columns = {
      fio: "Сотрудник",
      fzp: "Затр в бюджет",
      division: "Отдел",
      position: "Должность",
      location: "Местоположение"
    }
  end

  def money(value)
    ApplicationController.helpers.money(value, @current_user)
  end

end
