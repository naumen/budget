class CompanyBudgetCalculator

  attr_accessor :company_budget, :normativs_by_weight, :budgets_info

  def initialize(budget_metrik_calculator, budget=nil, calculate_all_budgets_itogo=nil)
    @budget = budget

    @f_year = budget_metrik_calculator.f_year
    @company_budget = {}
    @budgets_info = {}
    @budget_metriks = budget_metrik_calculator.budget_metriks
    @calculate_all_budgets_itogo = calculate_all_budgets_itogo

    # { normativ_id => weight, ... }
    @normativs_by_weight = calc_normativs_by_weight

    @invest_budgets   = get_invest_budgets
    @invest_b_ids     = @invest_budgets.map{|b| b.id}
    @invest_all_b_ids = get_invest_all_b_ids

    # b_id => []
    @budget_descendants = {}

  end

  def get_invest_budgets
    Budget.where(f_year: @f_year, budget_type_id: Budget.invest_type_ids)
  end

  def get_invest_all_b_ids
    ret = []
    @invest_budgets.each do |invest_budget|
      ret += invest_budget.self_and_descendants.map{|b| b.id}
    end
    ret.uniq
  end

  # company_budget:
  #
  # {
  #   budget_id1:
  #     in:
  #       nakladn:
  #       sales:
  #       invest:
  #       invest_zaim:
  #       itogo:
  #     out:
  #       nakladn:
  #       salary:
  #       invest:
  #       invest_zaim:
  #       zatratas:
  #       nakladn_details: [...]
  #       itogo:
  #
  #   budget_id2:
  #     in:
  #     out:
  #
  #   ...
  # }

  def calculate_company_budget
    calc_nakladn
    calc_sales
    calc_sales_nds
    calc_salary
    calc_zatratas
    calc_invest
    calc_invest_zaim

    calc_itogo

    if @calculate_all_budgets_itogo
      calc_all_budgets_info
    else
      calc_budgets_info if @budget
    end
    return @company_budget
  end

  private

  #   расчет по инвестиционным:
  #   - Бюджет с типом "Инвестиционный компании" - не должен суммировать наверх
  #     свои суммы использования по каждой группе (зп, затраты, накладные),
  #   - но если в бюджете есть вложенный бюджет относящийся к инвестиционной ветке,
  #     то его затраты (прямые, продажи, накладные) - отнести к разделу "invest" (sub)
  #
  def calc_budgets_info
    @budgets_info = {}

    budget_info = _calc_budget_info(@budget)
    @budgets_info[@budget.id] = budget_info.to_ostruct

    @budget.children.each do |b|
      budget_info = _calc_budget_info(b)
      @budgets_info[b.id] = budget_info.to_ostruct
    end

    @budgets_info
  end

  # подсчет по всем
  def calc_all_budgets_info
    @budgets_info = {}
    Budget.where( f_year: @f_year ).all.each do |budget|
      budget_info = _calc_budget_info(budget)
      @budgets_info[budget.id] = budget_info.to_ostruct
    end
  end

  def _calc_budget_info(budget)
    budget_id = budget.id
    info = { in: {}, out: {} }

    [:in, :out].each do |direction|
      _itogo = 0.0
      [:own, :sub].each do |kind|
        ret = _calc_budget_kind(kind, budget, direction)
        info[direction][kind] = ret
        _itogo += ret[:itogo]
      end
      info[direction][:itogo] = _itogo
    end

    info[:in][:nds] = _calc_budget_nds(budget)

    info
  end

  def get_budget_descendants(budget)
    if @budget_descendants[budget.id]
      # pass
    else
      @budget_descendants[budget.id] = budget.descendants
    end
    return @budget_descendants[budget.id]
  end

  # если бюджет компании то считаем доход - продажи, расход - затраты и зп
  def _calc_budget_kind(kind, budget, direction)
    ret = {}

    direction_types = if budget.is_top?
                        {
                          in:  [:sales],
                          out: [:salary, :zatratas]
                        }
                      else
                        {
                          in:  [:sales, :nakladn, :invest, :invest_zaim],
                          out: [:salary, :nakladn, :zatratas, :invest, :invest_zaim]
                        }
                      end

    _types = direction_types[direction]

    _itogo = 0.0
    if kind == :own
      _types.each do |t|
        val = @company_budget[budget.id][direction][t] rescue 0.0
        ret[t] = val
        _itogo += val
      end
    elsif kind == :sub
      # sub
      get_budget_descendants(budget).each do |b|
        # для "использования" "инвест"
        # для не верхнего бюджета, если дочерний входит в "инвест" ветку
        if !budget.is_top? && direction == :out && @invest_all_b_ids.include?(b.id)
          # исключаем суммы из Инвест бюджетов
          # но добавляем в инвест
          ret[:invest] ||= 0.0
          val = @company_budget[b.id][direction][:itogo] rescue nil
          if val
            ret[:invest] += val 
            _itogo += val
          end
        else
          _types.each do |t|
            ret[t] ||= 0.0
            val = @company_budget[b.id][direction][t] rescue nil
            if val
              ret[t] += val 
              _itogo += val
            end
          end
        end
      end # budget.descendants.each
    end
    ret[:itogo] = _itogo
    ret
  end

  def _calc_budget_nds(budget)
    nds = 0.0
    nds += @company_budget[budget.id][:in][:nds] rescue 0.0

    get_budget_descendants(budget).each do |b|
      nds += @company_budget[b.id][:in][:nds] rescue 0.0
    end
    return nds
  end

  # ==== INVEST

  def calc_invest
    invest_items = []
    sql = """
      SELECT
        from_budget_id,
        to_budget_id,
        summ
      FROM
        investment_projects
      WHERE
        f_year=#{@f_year}
    """
    Budget.connection.select_all(sql).each do |r|
      from_budget_id = r['from_budget_id']
      to_budget_id   = r['to_budget_id']
      invest_summa   = r['summ'].to_f

      handle_budget_delta(from_budget_id, :out, :invest, invest_summa, nil)
      handle_budget_delta(to_budget_id,   :in,  :invest, invest_summa, nil)
    end
  end

  # ==== INVEST ZAIM
  # use_budget_id    - Бюджет использования
  # credit_budget_id - Бюджет наполнения
  def calc_invest_zaim
    InvestLoan.all.each do |invest_zaim|
      from_budget_id = invest_zaim.use_budget_id
      to_budget_id   = invest_zaim.credit_budget_id
      invest_summa   = invest_zaim.summ

      # учитываем займ если есть возвраты
      if invest_zaim.use_budget.f_year == @f_year && !invest_zaim.repayment_loans.empty?
        handle_budget_delta(from_budget_id, :out, :invest_zaim, invest_summa, nil)
        handle_budget_delta(to_budget_id,   :in,  :invest_zaim, invest_summa, nil)
      end

      invest_zaim.repayment_loans.each do |invest_zaim_return|
        next if invest_zaim_return.fin_year != @f_year
        invest_summa_return = invest_zaim_return.summ

        # TODO 2 years ago..
        if invest_zaim.use_budget.f_year == @f_year - 1
          from_budget_id = invest_zaim.use_budget.next_budget.id
          to_budget_id   = invest_zaim.credit_budget.next_budget.id
        elsif invest_zaim.use_budget.f_year == @f_year - 2
          from_budget_id = invest_zaim.use_budget.next_budget.next_budget.id
          to_budget_id   = invest_zaim.credit_budget.next_budget.next_budget.id
        else
          from_budget_id = invest_zaim.use_budget_id
          to_budget_id   = invest_zaim.credit_budget_id
        end


        handle_budget_delta(from_budget_id, :in,  :invest_zaim, invest_summa_return, nil)
        handle_budget_delta(to_budget_id,   :out, :invest_zaim, invest_summa_return, nil)
      end
    end
  end

  # ==== ZATRATAS

  def calc_zatratas
    zatratas = {}
    sql = """
      SELECT
        stat_zatrs.budget_id,
        SUM(zatrats.summ) AS zatratas_summ
      FROM
        stat_zatrs,
        zatrats
      WHERE
        zatrats.stat_zatr_id = stat_zatrs.id
      GROUP BY
        stat_zatrs.budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      budget_id  = r['budget_id']
      zatratas_summ = r['zatratas_summ'].to_f
      zatratas[budget_id] = zatratas_summ
    end

    zatratas.each do |b_id, zatratas_summ|
      handle_budget_delta(b_id, :out, :zatratas, zatratas_summ, nil)
    end
  end

  # ==== SALARY

  def calc_salary
    salary = {}
    sql = """
      SELECT
        budget_id,
        SUM(summ) as salary_summ
      FROM
        salaries s, state_units su
      WHERE s.state_unit_id=su.id
      GROUP BY
        budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      budget_id  = r['budget_id']
      salary_summ = r['salary_summ'].to_f
      salary[budget_id] = salary_summ
    end

    salary.each do |b_id, salary_summ|
      handle_budget_delta(b_id, :out, :salary, salary_summ, nil)
    end
  end

  # ==== SALES

  def calc_sales
    sales = {}
    sql = """
      SELECT
        budget_id,
        SUM(summ) as sales_summ
      FROM
        sales
      GROUP BY
        budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      budget_id  = r['budget_id']
      sales_summ = r['sales_summ'].to_f
      sales[budget_id] = sales_summ
    end

    sales.each do |b_id, sales_summ|
      handle_budget_delta(b_id, :in, :sales, sales_summ, {})
    end
  end

  # ==== SALES NDS

  def calc_sales_nds
    nds_perc = 8
    sales_nds = {}
    Sale.where( f_year: @f_year, is_with_nds: true).all.each do |sale|
      budget_id  = sale.budget_id
      nds        = _calc_nds(sale.summ, nds_perc)
      sales_nds[budget_id] ||= 0.0
      sales_nds[budget_id] += nds
    end
    sales_nds.each do |b_id, nds|
      handle_budget_delta(b_id, :in, :nds, nds, {})
    end
  end

  def _calc_nds(summ, perc)
    summ.to_f / 100.0 * perc
  end

  # ==== WEIGHT

  def calc_normativs_by_weight
    ret = {}
    sql = """
      SELECT
        normativ_id,
        SUM(weight) as weight_itogo
      FROM
        naklads,
        normativs,
        metriks
      WHERE
        naklads.normativ_id=normativs.id
        AND normativs.metrik_id=metriks.id
        AND metriks.code='by_weight'
        AND naklads.archived_at IS NULL
        -- and naklads.f_year=2018
      GROUP BY
        normativ_id
    """
    Budget.connection.select_all(sql).each do |r|
      normativ_id  = r['normativ_id']
      weight_itogo = r['weight_itogo'].to_f
      ret[normativ_id] = weight_itogo
    end

    calc_normativs_by_equally.each do |n_id, cnt|
      ret[n_id] = cnt
    end

    ret
  end

  # по-ровну
  def calc_normativs_by_equally
    ret = {}
    sql = """
      SELECT
        normativ_id,
        count(*) as nakladn_cnt
      FROM
        naklads,
        normativs,
        metriks
      WHERE
        naklads.normativ_id=normativs.id
        AND normativs.metrik_id=metriks.id
        AND metriks.code='equally'
        AND naklads.archived_at IS NULL
        -- and naklads.f_year=2018
      GROUP BY
        normativ_id
    """
    Budget.connection.select_all(sql).each do |r|
      normativ_id  = r['normativ_id']
      weight_itogo = r['nakladn_cnt'].to_f
      ret[normativ_id] = weight_itogo
    end
    ret
  end


  # ==== NAKLADN

  #  логика: проходим по всем нормативам, что отмечены на бюджеты в матрице накладных
  #    для бюджета и норматива определяем метрику норматива
  #      берём из бюджета значение этой метрики
  #        умножаем значение норматива норматива на значение метрики = значение накладных
  #         плюсуем это значение бюджету поставщику
  #         минусуем это значение у бюджета потребителя
  def calc_nakladn
    calc_own_nakladn
  end

  def calc_itogo
    @company_budget.each do |b_id, in_out_values|
      [:in, :out].each do |direction|
        _itogo = 0.0
        case direction
        when :in
          ts = [:nakladn, :sales, :invest, :invest_zaim]
        when :out
          ts = [:nakladn, :invest, :invest_zaim, :zatratas, :salary]
        end

        if in_out_values[direction]
          ts.each do |t|
            _itogo += in_out_values[direction][t]
          end
          @company_budget[b_id][direction][:itogo] = _itogo
        end
      end
    end
  end

  def calc_own_nakladn
    items = Naklad.includes(:normativ => :metrik).where(f_year: @f_year).actual
    items.each do |nakladn|
      normativ = nakladn.normativ

      # бюджет источник норматива
      b_in_id  = normativ.budget_id

      # бюджет потребитель норматива
      b_out_id = nakladn.budget_id

      nakladn_meta  = calc_nakladn_value(nakladn, normativ, b_out_id)
      nakladn_value = nakladn_meta[:nakladn_value]

      if nakladn_value
        handle_budget_delta(b_out_id, :out, :nakladn, nakladn_value, nakladn_meta)
        handle_budget_delta(b_in_id,  :in,  :nakladn, nakladn_value, nakladn_meta)
      end
    end
  end

  def calc_nakladn_value(nakladn, normativ, b_id)
    nakladn_value = nil
    budget_metrik = nil
    if ["by_weight", "equally"].include?(normativ.metrik.code)
      normativ_weight_itogo = normativs_by_weight[normativ.id]

      # если поровную - то равно 1 иначе значение из накладной ячейки
      nakladn_weight = normativ.metrik.code == 'by_weight' ? nakladn.weight : 1

      nakladn_value = nakladn_weight / normativ_weight_itogo * normativ.norm
    else
      # получаем значение метрики Бюджета-потребителя
      metrik_code   = normativ.metrik.code.to_sym
      budget_metrik = @budget_metriks[b_id][metrik_code] rescue nil
      nakladn_value = normativ.norm * budget_metrik if budget_metrik
    end
    meta = {}
    meta[:normativ_id]   = normativ.id
    meta[:normativ_name] = normativ.name
    meta[:normativ_f_type] = normativ.normativ_type_id
    meta[:nakladn_weight]  = nakladn.weight
    meta[:metrik_name]   = normativ.metrik.name
    meta[:metrik_code]   = normativ.metrik.code
    meta[:metrik_value]  = budget_metrik
    meta[:norm]          = normativ.norm
    meta[:nakladn_value] = nakladn_value
    return meta
  end

  # direction = { :in | :out }
  # delta_type = { :nakladn | :sales | :zatratas | :salary }
  def handle_budget_delta(budget_id, direction, delta_type, delta_value, nakladn_meta)
    @company_budget[budget_id] ||= {}
    @company_budget[budget_id][direction] ||= get_empty_budget_info
    @company_budget[budget_id][direction][delta_type] +=  delta_value

    # keep nakladn_meta
    @company_budget[budget_id][direction][:nakladn_details] ||= []
    @company_budget[budget_id][direction][:nakladn_details] << nakladn_meta if nakladn_meta
  end

  def get_empty_budget_info
    {
      nakladn: 0.0, # +, -
      sales: 0.0, # +
      nds: 0.0, # -
      invest: 0.0, # +, -
      invest_zaim: 0.0, # +, -
      zatratas: 0.0, # -
      salary: 0.0, # -
      itogo: 0.0
    }
  end

end