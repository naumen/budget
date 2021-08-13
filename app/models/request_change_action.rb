class RequestChangeAction < ApplicationRecord
  belongs_to :request_change

  def action_type_name
     return 'Редактирование ст.затрат'  if action_type == 'stat_zatr_edit'
     return 'Создание ст.затрат'        if action_type == 'stat_zatr_create'
     return 'Создание шт.единицы'       if action_type == 'state_unit_create'
     return 'Редактирование шт.единицы' if action_type == 'state_unit_edit'
     return 'Изменить Резерв ФОТ'      if action_type == 'set_budget_fot'
     action_type
  end

  def delta
    delta = 0.0
    if action_type == 'state_unit_edit'
      _content = self.content
      _state_unid_id = _content["state_unit_id"]
      if self.request_change.state == 'Обработано'
        _budget_snapshot = self.request_change.get_budget_snapshot
        initial_state_unit = Budget.restore_state_unit(_state_unid_id, _budget_snapshot)
        salaries_as_hash   = Budget.restore_state_unit_salaries(_state_unid_id, _budget_snapshot)
      else
        initial_state_unit = StateUnit.find(_state_unid_id)
        salaries_as_hash = initial_state_unit.salaries_as_hash
      end
      itogo_before = 0.0
      itogo_after  = 0.0
      (1..12).to_a.each do |month_num|
        val = salaries_as_hash[month_num]
        itogo_before += val
        val = _content["salaries"][month_num-1][1].to_f
        itogo_after += val
      end
      delta = itogo_after - itogo_before
    end
    delta
  end

  def salaries_start
    salaries = {}
    content["salaries"].each do |s|
      salaries[s[0].to_i] = s[1]
    end
    ret = []
    Salary.as_salaries_start(salaries).map{|k,v| ret[k.to_i] = v}
    ret
  end

  def init_json
    self.json_content = initial_json
  end

  def initial_json
    if self.action_type == "state_unit_create"
      salaries = (1..12).to_a.map{|m| [m.to_s, "0"]}
      return { division: "", position: "", location_id: "", salaries: salaries}.to_json
    elsif self.action_type == "state_unit_edit"
      return { state_unit_id: "", division: "", position: "", location_id: "", salaries: [], salaries_start: {}}.to_json
    else
      return {} # error
    end
  end

  def content
    JSON.parse(self.json_content)
  end

  def handle
    @content = content
    case self.action_type
    when 'stat_zatr_edit'
      handle_stat_zatr_edit
    when 'stat_zatr_create'
      handle_stat_zatr_create
    when 'state_unit_create'
      handle_state_unit_create
    when 'state_unit_edit'
      handle_state_unit_edit
    when 'set_budget_fot'
      handle_set_budget_fot
    end
  end

  def handle_state_unit_edit
    _content = self.content

    state_unit = StateUnit.find(_content["state_unit_id"])

    state_unit_info = {}
    # state_unit_info["budget_id"] = self.request_change.budget_id
    state_unit_info["division"]    = _content["division"]    if _content["division"]
    state_unit_info["position"]    = _content["position"]    if _content["position"]
    state_unit_info["location_id"] = _content["location_id"] if _content["location_id"]

    if _content["salaries"]
      salary_map = {}
      _content["salaries"].each do |salary|
        salary_map[salary[0].to_s] = salary[1]
      end
      state_unit_info["salary_info"]  = salary_map
    end

    state_unit.set_change(state_unit_info)
    state_unit.on_update_salary

    # handle fot
    if _content['selectedStatZatrFot'] && _content['deltaStatZatrFot'] && _content['deltaStatZatrFot'].to_f.abs > 0.0
      stat_zatr = StatZatr.find(_content['selectedStatZatrFot'])
      _budget = stat_zatr.budget
      current_fot   = _budget.fot_value
      new_fot_value = current_fot - _content['deltaStatZatrFot'].to_f
      _budget.set_fot_value(new_fot_value, nil, self.request_change)
    end

  end

  def handle_state_unit_create
    state_unit = StateUnit.new
    state_unit.f_year = self.request_change.budget.f_year

    _content = self.content

    state_unit_info = {}
    state_unit_info["budget_id"] = self.request_change.budget_id
    state_unit_info["division"]  = _content["division"]
    state_unit_info["position"]  = _content["position"]
    state_unit_info["location_id"]  = _content["location_id"]
    salary_map = {}
    _content["salaries"].each do |salary|
      salary_map[salary[0].to_s] = salary[1]
    end
    state_unit_info["salary_info"]  = salary_map

    state_unit.set_change(state_unit_info)
    state_unit.clone_to_next_year
  end

  def handle_stat_zatr_edit
    stat_zatr_id = @content["stat_zatr_id"]
    f_year = request_change.budget.f_year
    @content["months"].each do |month, value|
      summ      = value[0].to_f
      is_beznal = value[1].to_i
      z = Zatrat.where(stat_zatr_id: stat_zatr_id, month: month).first
      if z.nil?
        z = Zatrat.new
        z.stat_zatr_id = stat_zatr_id
        z.month  = month
        z.f_year = f_year
      end
      z.nal_beznal = is_beznal
      z.summ       = summ
      z.save
    end
  end

  def handle_stat_zatr_create
    stat_zatr_name = @content["stat_zatr_name"]
    spr_stat_zatrs_id = @content["spr_stat_zatrs_id"]

    f_year = request_change.budget.f_year

    stat_zatr = StatZatr.new
    stat_zatr.name      = stat_zatr_name
    stat_zatr.budget_id = request_change.budget.id
    stat_zatr.all_summ  = 0.0
    stat_zatr.spr_stat_zatrs_id = spr_stat_zatrs_id
    stat_zatr.f_year            = f_year
    stat_zatr.save

    @content["months"].each do |month, value|
      summ      = value[0].to_f
      is_beznal = value[1].to_i == 1

      zatrat = Zatrat.new
      zatrat.month        = month
      zatrat.summ         = summ
      zatrat.nal_beznal   = is_beznal
      zatrat.stat_zatr_id = stat_zatr.id
      zatrat.f_year       = f_year
      zatrat.save
    end
  end

  def handle_set_budget_fot
    budget_fot_delta = @content['budget_fot_delta'].to_f
    # budget_fot_delta, user=nil, request_change=nil
    request_change.budget.set_fot_delta_value(budget_fot_delta, request_change.author, request_change)
  end

  def locations
    Location.all.order(:name)
  end

end
