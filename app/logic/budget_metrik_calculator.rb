class BudgetMetrikCalculator

  attr_accessor :own_budget_metriks, :budget_metriks, :budget_out_metriks, :invest_budget_ids, :f_year

  def initialize(f_year)
    @f_year = f_year
    @own_budget_metriks = {}
    @budget_metriks = {}
    @invest_budgets    = get_invest_budgets
    @invest_budget_ids = @invest_budgets.map{|b| b.id}
    @invest_all_b_ids  = get_invest_all_b_ids
    # вложенные суб-бюджеты, кто наверх не передают метрики
    @sub_budget_ids = Budget.sub_budget_ids

    # budget_id: {  invest: { metrik_code: val, ... }, sub: {...}  }
    @budget_out_metriks = {}

    b_top = Budget.top_budget(@f_year)
    @cur_year_budget_ids = b_top.descendants.map{ |b| b.id }

    # b_id => zatrats
    # without FOT
    @zatratas = calc_zatratas
  end

  def get_invest_all_b_ids
    ret = []
    @invest_budgets.each do |invest_budget|
      ret += invest_budget.self_and_descendants.map{|b| b.id}
    end
    ret.uniq
  end

  # { b_id: {metrik_code: val, ...}, ... }
  def calculate
    calc_own_budget_metriks
    summ_metriks_to_ancestors
    caclulate_top_budget
  end

  # в верхнем бюджете считаем все метрики что внизу (включая инвест)
  def caclulate_top_budget
    @b_top = Budget.top_budget(@f_year)
    # переписываем значения
    @budget_metriks[@b_top.id] = {}

    all_children_ids = @b_top.descendants.map{ |b| b.id }

    # все метрики что посчитаны в бюджетах - суммируем на верхний бюджет
    @own_budget_metriks.each do |budget_id, own_metriks|
      insert_own_to_budget_metriks(@b_top.id, own_metriks) if all_children_ids.include?(budget_id)
    end
  end


  def get_invest_budgets
    Budget.where(f_year: @f_year, budget_type_id: Budget.invest_type_ids)
  end

  # def get_invest_budget_ids
    # invest_budget_type = BudgetType.find_by_name("Инвестиционный компании")
    # Budget.where(budget_type_id: invest_budget_type.id, f_year: @f_year).map{|b| b.id}
  # end


  # add to FZP metrik
  def calc_delta_fot
    spr_fot  = SprStatZatr.get_fot_item
    metrik = :fzp
    sql = """
      SELECT
        stat_zatrs.budget_id as budget_id,
        SUM(zatrats.summ) as summa
      FROM
        zatrats,
        stat_zatrs
      WHERE
        stat_zatrs.spr_stat_zatrs_id = #{spr_fot.id}
        AND stat_zatrs.f_year = #{@f_year}
        AND zatrats.stat_zatr_id = stat_zatrs.id
      GROUP BY
        stat_zatrs.budget_id
    """
    item = {}
    Budget.connection.select_all(sql).each do |r|
      b_id  = r['budget_id']
      value = r['summa'].to_f
      item[b_id] = value
    end
    item.each do |b_id, fot_value|
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] ||= 0.0
      @own_budget_metriks[b_id][metrik] += fot_value
    end
  end  

  private

  def calc_own_budget_metriks
    calc_metrik_locations
    calc_metrik_locations_month
    calc_metrik_sales
    calc_metrik_fzp

    calc_delta_fot # add FOT to fzp metrik

    calc_metrik_fzp_by_locations
    calc_metrik_premii
    calc_metrik_fzp_and_premii
    calc_metrik_direct_costs
    calc_metrik_all_state_units_m
  end

  def get_budget_zatrataz(b_id)
    if @zatratas[b_id]
      return @zatratas[b_id]
    else
      0.0
    end
  end

  # суммируем две метрики в третью
  def calc_metrik_fzp_and_premii
    metrik = :fzp_and_premii
    catch_for_metriks = [:fzp, :premii]
    @own_budget_metriks.each do |b_id, metriks|
      catch_for_metriks.each do |m|
        if metriks.has_key?(m)
          @own_budget_metriks[b_id][metrik] ||= 0.0
          @own_budget_metriks[b_id][metrik] += @own_budget_metriks[b_id][m]
        end
      end
    end
  end

  # Прямые расходы
  # ФОТ (включая резерв ФОТ) + прямые расходы департамента
  def calc_metrik_direct_costs
    metrik = :direct_costs
    catch_for_metriks = [:fzp]
    with_metriks_budget_ids = []
    @own_budget_metriks.each do |b_id, metriks|
      with_metriks_budget_ids << b_id
      catch_for_metriks.each do |m|
        if metriks.has_key?(m)
          @own_budget_metriks[b_id][metrik] ||= 0.0
          @own_budget_metriks[b_id][metrik] += @own_budget_metriks[b_id][m]
        end
      end
      b_zatratas = get_budget_zatrataz(b_id)
      if b_zatratas && b_zatratas > 0.0
        @own_budget_metriks[b_id][metrik] ||= 0.0
        @own_budget_metriks[b_id][metrik] += b_zatratas
      end
    end
    # without fzp, just zatrats
    @zatratas.each do |b_id, b_zatratas|
      next if with_metriks_budget_ids.include?(b_id)
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] ||= 0.0
      @own_budget_metriks[b_id][metrik] += b_zatratas
    end
  end

  def calc_metrik_premii
    spr_premii = SprStatZatr.get_premii_item

    metrik = :premii
    spr_premii = SprStatZatr.get_premii_item
    sql = """
      SELECT
        stat_zatrs.budget_id as budget_id,
        SUM(zatrats.summ) as premii_summ
      FROM
        zatrats,
        stat_zatrs
      WHERE
        stat_zatrs.spr_stat_zatrs_id = #{spr_premii.id}
        AND stat_zatrs.f_year = #{@f_year}
        AND zatrats.stat_zatr_id = stat_zatrs.id
      GROUP BY
        stat_zatrs.budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      b_id  = r['budget_id']
      value = r['premii_summ'].to_f
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] = value
    end
  end

  # zatratas budget_id => summa
  def calc_zatratas
    zatratas = {}

    spr_fot  = SprStatZatr.get_fot_item
    
    sql = """
      SELECT
        stat_zatrs.budget_id,
        SUM(zatrats.summ) AS zatratas_summ
      FROM
        stat_zatrs,
        zatrats,
        budgets
      WHERE
        stat_zatrs.spr_stat_zatrs_id != #{spr_fot.id}
        AND budgets.id = stat_zatrs.budget_id
        AND zatrats.stat_zatr_id = stat_zatrs.id
        AND budgets.f_year = #{@f_year}
      GROUP BY
        stat_zatrs.budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      budget_id  = r['budget_id']
      next if @invest_all_b_ids.include?(budget_id)
      zatratas_summ = r['zatratas_summ'].to_f
      zatratas[budget_id] = zatratas_summ
    end
    zatratas
  end

  # @own_budget_metriks  -> @budget_metriks (+ to each budget's ancestor)
  def summ_metriks_to_ancestors
    @own_budget_metriks.each do |budget_id, own_metriks|
      next if !@cur_year_budget_ids.include?(budget_id)
      # copy self
      insert_own_to_budget_metriks(budget_id, own_metriks)

      is_out_budget_id = nil
      kind = nil
      if @invest_budget_ids.include?(budget_id) || @sub_budget_ids.include?(budget_id)
        is_out_budget_id = budget_id
        kind = @invest_budget_ids.include?(budget_id) ? :invest : :sub
      end
      _ancestors = get_budget_ancestors_ids(budget_id)
      _ancestors.each do |budget_ancestor_id|
        if is_out_budget_id.nil?
          insert_own_to_budget_metriks(budget_ancestor_id, own_metriks)
        else
          insert_own_to_budget_out_metriks(budget_ancestor_id, kind, own_metriks)
        end

        if is_out_budget_id.nil? && (@invest_budget_ids.include?(budget_ancestor_id) || @sub_budget_ids.include?(budget_ancestor_id))
          is_out_budget_id = budget_ancestor_id
          kind = @invest_budget_ids.include?(budget_ancestor_id) ? :invest : :sub
        end
      end
    end
  end

  def get_budget_ancestors_ids(budget_id)
    budget = Budget.find(budget_id)
    budget.ancestors.map{|b| b.id}.reverse
  end

  # ============= SALES

  def calc_metrik_sales
    metrik = :sales_total
    sql = """
      SELECT budget_id, sum(summ) AS sales_summ
      FROM sales
      GROUP BY budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      b_id = r['budget_id']
      value  = r['sales_summ'].to_f
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] = value
    end
  end

  # ============= FZP by locations
  # помесячно - только не нулевые з/п
  def calc_metrik_fzp_by_locations
    # fzp_by_location
    # fzp_by_location_chel
    # fzp_by_location_msk
    # fzp_by_location_sev
    # fzp_by_location_twr
    # fzp_by_location_spb
    # fzp_by_location_kdr

    location_metriks = Location.location_metriks

    remote_location_ids = _remote_location_ids(location_metriks)

    exclude_remote = ''
    if !remote_location_ids.empty?
      exclude_remote += " AND location_id not in (#{remote_location_ids.join(',')})"
    end

    # location_state_unit_...
    location_metriks.each do |metrik_postfix, city_name|
      _metrik_postfix = ''
      if metrik_postfix == 'ekb'
        # pass
      elsif metrik_postfix == 'krym'
        _metrik_postfix = '_sev'
      else
        _metrik_postfix = '_' + metrik_postfix
      end

      metrik_code = "fzp_by_location#{_metrik_postfix}".to_sym
      city = City.find_by_name(city_name) rescue nil
      next if city.nil?
      metrik = :fzp
      sql = """
        SELECT
          budget_id,
          SUM(s.summ) AS fzp
        FROM
          salaries s,
          state_units su,
          locations l
        WHERE
          s.summ > 0.0
          AND s.state_unit_id = su.id
          AND su.location_id=l.id
          AND l.city_id=#{city.id}
          #{exclude_remote}
        GROUP BY
          su.budget_id
      """
      Budget.connection.select_all(sql).each do |r|
        b_id = r['budget_id']
        value  = r['fzp'].to_f
        @own_budget_metriks[b_id] ||= {}
        @own_budget_metriks[b_id][metrik_code] = value
      end
    end
  end

  # ============= FZP

  def calc_metrik_fzp
    metrik = :fzp
    sql = """
      SELECT
        budget_id,
        SUM(salaries.summ) AS fzp
      FROM
        salaries,
        state_units
      WHERE
        salaries.state_unit_id = state_units.id
      GROUP BY
        state_units.budget_id
	  """
    Budget.connection.select_all(sql).each do |r|
      b_id = r['budget_id']
      value  = r['fzp'].to_f
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] = value
    end
  end

  # all state units month
  # все ШЕ помесячно :: all_state_units_m
  def calc_metrik_all_state_units_m
    metrik_code = "all_state_units_m".to_sym

    sql = """
      SELECT
        budget_id,
        count(*) AS cnt
      FROM
        state_units su,
        salaries s,
        locations l
      WHERE
        s.summ > 0.0
        AND su.location_id  = l.id
        AND s.state_unit_id = su.id
        AND su.location_id != #{Location.free_location_id}
        AND su.location_id != #{Location.maternity_leave_location_id}
      GROUP BY
        budget_id
    """
    Budget.connection.select_all(sql).each do |r|
      b_id = r['budget_id']
      cnt  = r['cnt'].to_i
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik_code] = cnt
    end
  end

  # ============= LOCATIONS month
  # помесячно - только не нулевые з/п
  def calc_metrik_locations_month
    # location_state_unit_msk
    # location_state_unit_twr
    # location_state_unit_chel
    # location_state_unit_kiev
    # location_state_unit_spb
    # location_state_unit_kdr
    location_metriks = Location.location_metriks

    remote_location_ids = _remote_location_ids(location_metriks)

    exclude_remote = ''
    if !remote_location_ids.empty?
      exclude_remote += " AND location_id not in (#{remote_location_ids.join(',')})"
    end

    # location_state_unit_...
    location_metriks.each do |metrik_postfix, city_name|
      metrik_code = "location_state_unit_#{metrik_postfix}_m".to_sym
      city = City.find_by_name(city_name) rescue nil
      next if city.nil?

      sql = """
        SELECT
          budget_id,
          count(*) AS cnt
        FROM
          state_units su,
          salaries s,
          locations l
        WHERE
          s.summ > 0.0
          AND su.location_id = l.id
          AND s.state_unit_id=su.id
          AND l.city_id=#{city.id}
          #{exclude_remote}
        GROUP BY
          budget_id
      """
      Budget.connection.select_all(sql).each do |r|
        b_id = r['budget_id']
        cnt  = r['cnt'].to_i
        @own_budget_metriks[b_id] ||= {}
        @own_budget_metriks[b_id][metrik_code] = cnt
      end
    end
  end

  # ============= LOCATIONS

  def _remote_location_ids(location_metriks)
    remote_location_ids = []
    location_metriks.each do |_, city_name|
      remote_location_name = "#{city_name}, удаленно"
      location = Location.find_by_name(remote_location_name) rescue nil
      remote_location_ids << location.id if location
    end
    remote_location_ids
  end

  def calc_metrik_locations
    # metrik_code_postfix, city_name
    location_metriks = Location.location_metriks

    # получение ид удаленых локаций
    # mask: "Название_города, удаленно"
    remote_location_ids = _remote_location_ids(location_metriks)

    # location_state_unit_external
    metrik = :location_state_unit_external
    if !remote_location_ids.empty?
      sql = """
        SELECT budget_id, count(*) AS cnt
        FROM state_units
        WHERE location_id in (#{remote_location_ids.join(',')})
        GROUP BY budget_id
      """
      Budget.connection.select_all(sql).each do |r|
        b_id = r['budget_id']
        cnt  = r['cnt'].to_i
        @own_budget_metriks[b_id] ||= {}
        @own_budget_metriks[b_id][metrik] = cnt
      end
    end

    # all
    metrik = :all_state_units
    # для всех учитываем Удаленно
    #     addon = 'where 1=1'
    #     if !remote_location_ids.empty?
    #       addon += " AND location_id not in (#{remote_location_ids.join(',')})"
    #     end
    # но исключаем Свободный Человек, Декретный отпуск

    sql = """
      SELECT budget_id, count(*) as cnt
      FROM state_units
      WHERE
        archive_date IS NULL
        AND location_id != #{Location.free_location_id}
        AND location_id != #{Location.maternity_leave_location_id}
      GROUP BY budget_id
     """
    Budget.connection.select_all(sql).each do |r|
      b_id = r['budget_id']
      cnt  = r['cnt'].to_i
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] = cnt
    end

    # free man
    metrik = :free_man
    # Свободный Человек
    sql = """
      SELECT budget_id, count(*) as cnt
      FROM state_units
      WHERE
        archive_date IS NULL
        AND location_id = #{Location.free_location_id}
      GROUP BY budget_id
     """
    Budget.connection.select_all(sql).each do |r|
      b_id = r['budget_id']
      cnt  = r['cnt'].to_i
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] = cnt
    end

    # maternity_leave
    metrik = :maternity_leave
    # Декретный отпуск
    sql = """
      SELECT budget_id, count(*) as cnt
      FROM state_units
      WHERE
        archive_date IS NULL
        AND location_id = #{Location.maternity_leave_location_id}
      GROUP BY budget_id
     """
    Budget.connection.select_all(sql).each do |r|
      b_id = r['budget_id']
      cnt  = r['cnt'].to_i
      @own_budget_metriks[b_id] ||= {}
      @own_budget_metriks[b_id][metrik] = cnt
    end


    # location_state_unit_...
    location_metriks.each do |metrik_postfix, city_name|
      metrik_code = "location_state_unit_#{metrik_postfix}".to_sym
      city = City.find_by_name(city_name) rescue nil
      next if city.nil?

      addon = '1=1'
      if !remote_location_ids.empty?
        addon = "location_id not in (#{remote_location_ids.join(',')})"
      end

      # AND su.archive_date is null
      sql = """
        SELECT
          budget_id,
          count(*) AS cnt
        FROM
          state_units su,
          locations l
        WHERE
          #{addon}
          AND su.location_id = l.id
          AND l.city_id=#{city.id}
        GROUP BY
          budget_id
      """
      Budget.connection.select_all(sql).each do |r|
        b_id = r['budget_id']
        cnt  = r['cnt'].to_i
        @own_budget_metriks[b_id] ||= {}
        @own_budget_metriks[b_id][metrik_code] = cnt
      end
    end

  end

  def insert_own_to_budget_metriks(budget_id, own_metriks)
    @budget_metriks[budget_id] ||= {}
    own_metriks.each do |metrik_code, val|
      # add if exists
      if @budget_metriks[budget_id][metrik_code]
        @budget_metriks[budget_id][metrik_code] += val
      else
      # new val
        @budget_metriks[budget_id][metrik_code] = val
      end
    end
  end

  # добавление инвест, суб - те что не считаются
  # kind: invest | sub
  def insert_own_to_budget_out_metriks(budget_id, kind, own_metriks)
    @budget_out_metriks[budget_id] ||= {}
    @budget_out_metriks[budget_id][kind] ||= {}
    own_metriks.each do |metrik_code, val|
      # add if exists
      if @budget_out_metriks[budget_id][kind][metrik_code]
        @budget_out_metriks[budget_id][kind][metrik_code] += val
      else
      # new val
        @budget_out_metriks[budget_id][kind][metrik_code] = val
      end
    end
  end

end
