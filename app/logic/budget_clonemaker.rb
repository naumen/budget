class BudgetClonemaker
  def initialize(f_year)
    @f_year = f_year
    @f_year_next = @f_year + 1
  end

  def clone_all
      p 'clone_budgets'
    clone_budgets
      p 'clone_stat_zatrs_and_zatrats'
    clone_stat_zatrs_and_zatrats
      p 'clone_normativs'
    clone_normativs
      p 'clone_state_units_and_salaries'
    clone_state_units_and_salaries
      p 'clone_naklad'
    clone_naklad
      p 'clone_sale_channels'
    clone_sale_channels
  end

  def clone_sale_channels
    SaleChannel.where(f_year: @f_year_next).delete_all
    SaleChannel.where(f_year: @f_year).all.each do |sale_channel|
      cloned_sale_channel = SaleChannel.new
      cloned_sale_channel.f_year = @f_year_next
      cloned_sale_channel.name   = sale_channel.name
      cloned_sale_channel.save
    end
  end

  def clone_state_units_and_salaries
    # old_id => { new_id: ..., salary_12: ... }
    new_state_unit_ids = {}

    # clone state_units
    # клонируем шт.единицы на следующий год только если не нулевая з/п на 12 месяц
    StateUnit.where(f_year: @f_year_next).delete_all
    StateUnit.where(f_year: @f_year).all.each do |state_unit|
      # nil if empty of 0.0
      salary_by_december = state_unit.salary_by_december
      if salary_by_december
        cloned_state_unit = state_unit.dup

        cloned_state_unit.id        = nil
        cloned_state_unit.parent_id = state_unit.id
        cloned_state_unit.f_year    = @f_year_next
        cloned_state_unit.budget_id = state_unit.budget.next_budget_id
        cloned_state_unit.staff_item_id = state_unit.staff_item_id
        cloned_state_unit.save
        new_state_unit_ids[state_unit.id] = {
          id: cloned_state_unit.id, 
          salary: salary_by_december
        }
      end
    end

    # clone salaries
    Salary.where(f_year: @f_year_next).delete_all
    new_state_unit_ids.each do |old_id, info|
      state_unit_id = info[:id]
      salary        = info[:salary]

      (1..12).to_a.each do |month|
        new_salary = Salary.new
        new_salary.state_unit_id = state_unit_id
        new_salary.summ   = salary
        new_salary.f_year = @f_year_next
        new_salary.month  = month
        new_salary.save
      end
    end
  end

  def clone_naklad
    Naklad.where(f_year: @f_year_next).delete_all
    Naklad.where(f_year: @f_year).all.each do |naklad|
      cloned_naklad = naklad.dup
      cloned_naklad.f_year      = @f_year_next
      cloned_naklad.budget_id   = naklad.budget.next_budget_id
      cloned_naklad.normativ_id = naklad.normativ.normativ_in_next_year.id
      cloned_naklad.save
    end
  end

  def clone_normativs
    Normativ.where(f_year: @f_year_next).delete_all
    Normativ.where(f_year: @f_year).all.each do |normativ|
      cloned_normativ = normativ.dup

      cloned_normativ.id        = normativ.id + 10000
      cloned_normativ.f_year    = @f_year_next
      cloned_normativ.budget_id = normativ.budget.next_budget_id
      cloned_normativ.normativ_in_prev_year_id = normativ.id
      cloned_normativ.save
    end
  end

  def clone_stat_zatrs_and_zatrats
    # stat_zatrs
    new_stat_zatr_ids = {}
    StatZatr.where(f_year: @f_year_next).delete_all
    StatZatr.where(f_year: @f_year).all.each do |stat_zatr|
      cloned_stat_zatr = stat_zatr.dup
      cloned_stat_zatr.f_year    = @f_year_next
      cloned_stat_zatr.budget_id = stat_zatr.budget.next_budget_id
      cloned_stat_zatr.save
      new_stat_zatr_ids[stat_zatr.id] = cloned_stat_zatr.id
    end

    # zatrats
    Zatrat.where(f_year: @f_year_next).delete_all
    Zatrat.where(f_year: @f_year).all.each do |zatrat|
      cloned_zatrat = zatrat.dup
      cloned_zatrat.f_year       = @f_year_next
      cloned_zatrat.stat_zatr_id = new_stat_zatr_ids[cloned_zatrat.stat_zatr_id]
      cloned_zatrat.save
    end

  end

  def clone_budgets
    Budget.where(f_year: @f_year_next).delete_all

    budget_root = Budget.where( parent_id: nil, f_year: @f_year).first
    # id => cloned_id
    @new_budget_ids = {}
    budget_root.self_and_descendants.each do |budget|
      next if budget.budget_type && budget.budget_type.name == 'ПЕРЕНОС внутренний'
      cloned_budget_id = _clone_budget(budget)
      @new_budget_ids[budget.id] = cloned_budget_id
    end
  end

  def _clone_budget(b)
    cloned = b.dup

    cloned.id     = b.id + 10000
    cloned.f_year = @f_year_next
    cloned.prev_budget_id = b.id
    cloned.parent_id = @new_budget_ids[cloned.parent_id] if cloned.parent_id

    cloned.all_zatrats_summ = 0
    cloned.all_dohods_summ  = 0
    cloned.next_budget_id   = nil
    cloned.itogo_usage = 0.0
    cloned.budget_info = nil
    cloned.itogo_in    = 0.0
    cloned.state       = 'Черновик'

    cloned.save

    cloned_budget_id = cloned.id
    b.next_budget_id = cloned_budget_id
    b.save

    cloned_budget_id
  end

end