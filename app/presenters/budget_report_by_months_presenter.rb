class BudgetReportByMonthsPresenter

  attr_accessor :skip_itogo_row

  def initialize(budget, budget_presenter)
    @budget_presenter = budget_presenter
    @budget_info    = @budget_presenter.budget_info
    @budget_nakladn = @budget_info.out.own.nakladn.to_f

    @budget = budget
    @b_ids  = @budget.self_and_descendants.map{ |b| b.id }
  end

  def months
    months = (1..12).to_a
  end

  def rows
    @itogo_zatrat_name_rows = ["ЗПЛ", "ПФ", "Прямые расходы", "Накладные расходы"]
    @itogo_staff_item_name_rows = ["ШЕ по Екб", "ШЕ по Мск", "ШЕ по Тверь", 
      "ШЕ по Члб", "ШЕ по СПб", "ШЕ по Севастополь", "ШЕ по Краснодар"]
    
    @skip_itogo_row = ['Кол-во ШЕ всего, без СЧ'] + @itogo_staff_item_name_rows + ["ШЕ СЧ"]
    # ВСЕГО затрат
    # ЗПЛ
    # ПФ
    # Прямые расходы
    # Накладные расходы
    # Кол-во ШЕ всего, без СЧ
    # ШЕ по Екб
    # ШЕ по Мск
    # ШЕ по Спб
    # ...
    # ШЕ СЧ

    items = []
    items << _itogo
    items << _calc_zp
    items << _calc_pf
    items << _calc_zatrats_direct
    items << _calc_zatrats_nakladn

    _add_staff_items_rows(items)

    _handle_itogo_by_row(items)

    _handle_itogo_by_cols(items, "zatrats")
    _handle_itogo_by_cols(items, "staff_items")

    items
  end

  def _add_staff_items_rows(items)
    items << { name: "Кол-во ШЕ всего, без СЧ", cols: {} }


    locations = []
    locations << ["ШЕ по Екб",   2]
    locations << ["ШЕ по Мск",   1]
    locations << ["ШЕ по Тверь", 3]
    locations << ["ШЕ по Члб",   4]
    # locations << ["ШЕ по Пермь", 5]
    locations << ["ШЕ по СПб",   7]
    # locations << ["ШЕ по Астана", 8]
    locations << ["ШЕ по Севастополь", 11]
    locations << ["ШЕ по Краснодар", 13]
    locations << ["ШЕ СЧ", 12]

    locations.each do |name, city_id|
      items << { name: name, cols: _calc_staff_items_by_city(city_id)}
    end

  end

  # шт.единицы по городам, по месяцам
  def _calc_staff_items_by_city(city_id)
    staff_items_per_month = {}
    sql = """
      SELECT
        s.month as month,
        count(*) AS cnt_per_month
      FROM
        state_units su,
        salaries s,
        locations l
      WHERE
        s.summ > 0.0
        AND su.location_id = l.id
        AND s.state_unit_id=su.id
        AND l.city_id=#{city_id}
        AND su.budget_id IN (#{@b_ids.join(', ')})
      GROUP BY s.month
    """
    Budget.connection.select_all(sql).each do |row|
      month         = row['month'].to_i
      cnt_per_month = row['cnt_per_month'].to_i
      staff_items_per_month[month] = cnt_per_month
    end

    cols = {}
    months.each do |month_num|
      cols[month_num] = staff_items_per_month[month_num] || 0.0
    end
    cols
  end


  # считаем что 0 строка - это ИТОГО
  def _handle_itogo_by_cols(rows, kind)
    if kind == "zatrats"
      name_rows = @itogo_zatrat_name_rows
      row_itogo_pos = 0
    elsif kind == "staff_items"
      name_rows = @itogo_staff_item_name_rows
      row_itogo_pos = @itogo_zatrat_name_rows.size + 1
    end
      
    all_cols = [:itogo] + months
    all_cols.each do |col_name|
      col_itogo = 0.0
      rows.each do |row|
        next if !name_rows.include?(row[:name])
        row_value = col_name == :itogo ? row[:itogo] : row[:cols][col_name]
        col_itogo += row_value || 0.0
      end
      if col_name == :itogo
        rows[row_itogo_pos][:itogo] = col_itogo
      else
        rows[row_itogo_pos][:cols][col_name] = col_itogo
      end
    end
  end


  def _itogo
    { name: "ВСЕГО затрат", cols: {} }
  end

  # ЗП
  def _calc_zp
    budget_zp_per_month = {}
    
    sql = """
      SELECT
        s.month AS month,
        SUM(s.summ) zp_per_month
      FROM
        state_units su,
        salaries s
      WHERE
        s.state_unit_id = su.id
        AND su.budget_id IN (#{@b_ids.join(', ')})
      GROUP BY
        month
    """
    Budget.connection.select_all(sql).each do |row|
      month = row['month'].to_i
      zp_per_month = row['zp_per_month'].to_f
      budget_zp_per_month[month] = zp_per_month
    end

    cols = {}
    months.each do |month_num|
      cols[month_num] = budget_zp_per_month[month_num] || 0.0
    end
    { name: "ЗПЛ", cols: cols }
  end

  # ПФ
  def _calc_pf
    budget_premii_per_month = _get_zatrats(true) # затраты-премии
    cols = {}
    months.each do |month_num|
      cols[month_num] = budget_premii_per_month[month_num] || 0.0
    end
    { name: "ПФ", cols: cols }
  end

  # Прямые расходы - затраты (статьи затрат), без Премий
  def _calc_zatrats_direct
    budget_zatrats_per_month = _get_zatrats(false) # затрата - кроме премий
    cols = {}
    months.each do |month_num|
      cols[month_num] = budget_zatrats_per_month[month_num] || 0.0
    end
    { name: "Прямые расходы", cols: cols }
  end

  # Накладные расходы
  # годовые накладные делим на 12 - на каждый месяц
  def _calc_zatrats_nakladn
    budget_nakladn_per_month = @budget_nakladn / 12.0
    cols = {}
    months.each do |month_num|
      cols[month_num] = budget_nakladn_per_month
    end
    { name: "Накладные расходы", cols: cols }
  end

  # один метод для получения затрат типа "Премии", и остальных затрат (без премии)
  def _get_zatrats(is_premii=false)
    zatrats_per_month = {}

    spr_stat_zatrs_premii_id = SprStatZatr.get_premii_item.id

    premii_cond = if is_premii
      "sz.spr_stat_zatrs_id = #{spr_stat_zatrs_premii_id}"
    else
      "(sz.spr_stat_zatrs_id IS NULL OR sz.spr_stat_zatrs_id != #{spr_stat_zatrs_premii_id})"
    end

    sql = """
      SELECT
        z.month AS month,
        SUM(z.summ) AS zatrats_per_month
      FROM
        stat_zatrs sz,
        zatrats z
      WHERE
        #{premii_cond}
        AND z.stat_zatr_id = sz.id
        AND sz.budget_id IN (#{@b_ids.join(', ')})
      GROUP BY
        month
    """
    Budget.connection.select_all(sql).each do |row|
      month        = row['month'].to_i
      z_per_month  = row['zatrats_per_month'].to_f
      zatrats_per_month[month] = z_per_month
    end
    zatrats_per_month
  end

  def _handle_itogo_by_row(items, options = nil)
    items.each do |item|
      next if options && options[:skip_rows].include?(item[:name])
      item[:itogo] = _calc_col_itogo(item[:cols])
    end
  end

  def _calc_col_itogo(cols)
    itogo = 0.0
    months.each do |month_num|
      itogo += cols[month_num] || 0.0
    end
    itogo
  end


end