
# Model BudgetMetrik
class BudgetMetrik < ApplicationRecord
  belongs_to :budget, foreign_key: 'budget_id'
  belongs_to :metrik, foreign_key: 'metrik_id', optional: true
  belongs_to :location, class_name: 'SprLocation', foreign_key: 'location_id', optional: true

  scope :actual, -> { where(archived_at: nil) }

  # SERIALIZATION
  def self.archive_active_now(archive_at, f_year)
    BudgetMetrik.where(archived_at: nil, f_year: f_year).update_all(archived_at: archive_at)
  end

  # сериализуем матрицу метрик бюджетов, с собственными метриками и со всеми метриками
  def self.serialize_budget_metriks(budget_metriks_own, budget_metriks, archive_at, f_year)
    # удаляем все
    BudgetMetrik.archive_active_now(archive_at, f_year)

    # budget_id => { metrik_code => { value: ..., value_own: ...}, metrik_code2 => ... }, ...
    to_store = {}

    # own and all
    [ [budget_metriks_own, :value_own], [budget_metriks, :value] ].each do |budget_metriks, f_name|
      budget_metriks.each do |b_id, metriks|
        to_store[b_id] ||= {}
        metriks.each do |metrik_code, metrik_value|
          to_store[b_id][metrik_code] ||= {}
          to_store[b_id][metrik_code][f_name]= metrik_value
        end
      end
    end

    budget_ids_for_year = Budget.budget_ids_for_year(f_year)

    # store to database
    to_store.each do |b_id, metriks|
      # сохраняем только для указанного года метрики бюджетов
      next if !budget_ids_for_year.include?(b_id)
      metriks.each do |metrik_code, metrik_values|
        metrik = Metrik.find_by_code(metrik_code)
        budget_metrik = {
          f_year:    f_year,
          budget_id: b_id,
          metrik_id: metrik.id,
          value_own: metrik_values[:value_own],
          value:     metrik_values[:value]
        }
        ret = BudgetMetrik.create(budget_metrik)
      end
    end
  end

  # востанавливаем значения (own_budget_metriks, budget_metriks)
  def self.restore_budget_metriks
    own_budget_metriks = {}
    budget_metriks     = {}
    BudgetMetrik.actual.each do |rec|
      budget_id = rec.budget_id
      metrik    = rec.metrik
      value     = rec.value
      value_own = rec.value_own

      if value_own
        own_budget_metriks[budget_id] ||= {}
        own_budget_metriks[budget_id][metrik.code.to_sym] = value_own
      end

      if value
        budget_metriks[budget_id] ||= {}
        budget_metriks[budget_id][metrik.code.to_sym] = value
      end
    end
    return [own_budget_metriks, budget_metriks]
  end

  # /SERIALIZATION

  def self.calculate_and_store_metriks(f_year, archive_at=nil)
    require_relative '../logic/budget_metrik_calculator.rb'
    budget_metrik_calculator = BudgetMetrikCalculator.new(f_year)
    budget_metrik_calculator.calculate

    BudgetMetrik.serialize_budget_metriks(budget_metrik_calculator.own_budget_metriks, budget_metrik_calculator.budget_metriks, archive_at, f_year)
  end

  def self.restore_calculated_metriks(budget_metrik_calculator)
    own_budget_metriks, budget_metriks = BudgetMetrik.restore_budget_metriks
    budget_metrik_calculator.own_budget_metriks = own_budget_metriks
    budget_metrik_calculator.budget_metriks = budget_metriks
  end

  def self.budget_metriks(f_year)
    require_relative '../logic/budget_metrik_calculator.rb'
    budget_metrik_calculator = BudgetMetrikCalculator.new(f_year)
    budget_metrik_calculator.calculate
    budget_metrik_calculator.budget_metriks
  end


  # what is this?
  def self.metrik_create_in_year(year)
    budget_metriks_array = []

    Budget.where(f_year: year).each do |budget|
      BudgetMetrik.where(budget_id: budget.id).delete_all
      budget_ids = budget.self_and_descendants.pluck(:id)

      unless StateUnit.where(budget_id: budget_ids).empty?
        #1 метрика Общее кол-во штатных единиц
        budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "all_state_units").id, value: StateUnit.where(budget_id: budget_ids).size, city: nil, sale_channel_id: nil })

        #2 метрика Кол-во штатных единиц в локации
        SprLocation.distinct(:city).pluck(:city).each do |city|
          state_units_size = StateUnit.where(budget_id: budget_ids).includes(:location).where(spr_locations: { city: city }).size
          if state_units_size > 0
            budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "location_state_unit").id, value: state_units_size, city: city, sale_channel_id: nil })
          end
        end

        #3 метрика Кол-во вакантных штатных единиц в локации
        SprLocation.distinct(:city).pluck(:city).each do |city|
          state_units_size = StateUnit.where(budget_id: budget_ids).where(user_id: nil).includes(:location).where(spr_locations: { city: city }).size
          if state_units_size > 0
            budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "state_units_vakant").id, value: state_units_size, city: city, sale_channel_id: nil })
          end
        end

        #4 метрика Кол-во месячных затрат ШЕ в локации
        SprLocation.distinct(:city).pluck(:city).each do |city|
          count_salary = Salary.where("summ > 0").includes(:state_unit).where(state_units: { id: StateUnit.where(budget_id: budget_ids).includes(:location).where(spr_locations: { city: city }).pluck(:id) }).count

          # budget.state_units.each do |state_unit|
          #   if state_unit.location_id == location.id
          #     count_salary += state_unit.salaries.count
          #   end
          # end

          if count_salary > 0
            budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "month_location_state_unit").id, value: count_salary, city: city, sale_channel_id: nil })
          end
        end

        #5 метрика Общий объем ФЗП
        fzp = Salary.includes(:state_unit).where(state_units: { id: StateUnit.where(budget_id: budget_ids) }).sum(:summ).to_f
        budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "fzp").id, value: fzp, city: nil, sale_channel_id: nil })

        #9 метрика Объем ФЗП в бюджете в локации
        SprLocation.distinct(:city).pluck(:city).each do |city|
          fzp = Salary.includes(:state_unit).where(state_units: { id: StateUnit.where(budget_id: budget_ids).includes(:location).where(spr_locations: { city: city }).pluck(:id) }).sum(:summ).to_f
          if fzp > 0
            budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "fzp_by_location").id, value: fzp, city: city, sale_channel_id: nil })
          end
        end
      end

      #6 метрика Объем продаж через канал
      SaleChannel.all.each do |sale_channel|
        sale_money = Sale.where(budget_id: budget.id, sale_channel_id: sale_channel.id).sum(:summ)
        if sale_money > 0
          budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "sales_from_channel").id, value: sale_money, city: nil, sale_channel_id: sale_channel.id })
        end
      end

      #8 метрика Общий объем продаж
      sale_money = budget.sale.sum(:summ)
      if sale_money > 0
        budget_metriks_array.push({ budget_id: budget.id, metrik_id: Metrik.find_by(code: "sales_total").id, value: sale_money, city: nil, sale_channel_id: nil })
      end
    end

    a = BudgetMetrik.create(budget_metriks_array)
  end
end
