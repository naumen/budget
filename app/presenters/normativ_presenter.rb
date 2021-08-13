class NormativPresenter
  def initialize(f_year, normativ_type_id)
    @f_year   = f_year
    @normativ_type_id = normativ_type_id
  end

  def money_cols
    [:norm, :norm_prev, :budget_usage_prev, :budget_usage, :budget_usage_delta]
  end

  def cols
    {
      name: "Наименование",
      norm: "Норматив",
      metrik: "Метрика",
      cfo:    "ЦФО",
      budget: "Бюджет",
      description: "Описание",
      sostav_zatrat: "Состав затрат",
      kind: "Отнесен",
      norm_prev: "Норм #{@f_year-1}",
      delta: "Разница",
      delta_perc: "Разница, %",
      budget_usage_prev: "Исп. #{@f_year-1}",
      budget_usage: "Исп. #{@f_year}",
      budget_usage_delta: "Исп. Разница",
      budget_usage_delta_perc: "Исп. Разница, %",
    }
  end

  def rows
    rows = []
    Normativ.where(conditions).all.each do |normativ|
      row = {}
      row[:id]   = normativ.id
      row[:name] = normativ.name
      row[:norm] = normativ.norm
      row[:metrik] = normativ.metrik.name
      row[:cfo]    = normativ.budget.cfo.name rescue ''
      row[:budget] = normativ.budget.name
      row[:description]   = normativ.description
      row[:sostav_zatrat] = normativ.sostav_zatrat
      row[:kind]   = normativ.normativ_type.name rescue ''

      row[:norm_prev]  = nil
      row[:delta]      = nil
      row[:delta_perc] = nil

      normativ_prev   = normativ.normativ_in_prev_year

      if normativ_prev
        row[:norm_prev] = normativ_prev.norm
        normativ_delta  = normativ.norm - normativ_prev.norm
        row[:delta] = "#{'+' if normativ_delta > 0.0}#{normativ_delta}"
        row[:delta_perc] = "%0.2f%" % (normativ_delta / normativ_prev.norm*100.0)
      end

      # budget usage
      if normativ.budget.prev_budget
        row[:budget_usage_prev]  = normativ.budget.prev_budget.itogo_usage
        row[:budget_usage]       = normativ.budget.itogo_usage
        row[:budget_usage_delta] = row[:budget_usage] - row[:budget_usage_prev]
        row[:budget_usage_delta_perc] = "%0.2f" % ( row[:budget_usage_delta] / row[:budget_usage_prev] * 100.0)
      end

      rows << row
    end
    rows
  end

  private

  def conditions
    ret = {}
    ret[:f_year] = @f_year
    ret[:normativ_type_id] = @normativ_type_id if @normativ_type_id
    ret[:normativ_type_id] = nil if @normativ_type_id == '__empty__'
    ret
  end


end