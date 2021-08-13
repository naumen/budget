require 'test_helper'

class BudgetClonemakerTest < ActiveSupport::TestCase

  def setup
    Budget.rebuild!
    @f_year = 2018
    @f_year_next = @f_year + 1


    @budget_clonemaker = BudgetClonemaker.new(@f_year)
    @normativ_it_base = normativs(:normativ_it_base) # for test next year
  end

  test "exists" do
    assert_instance_of BudgetClonemaker, @budget_clonemaker
  end

  test "clone budgets" do
    @budget_clonemaker.clone_budgets
    assert_equal 11, Budget.where(f_year: @f_year_next).count
  end

  test "clone budget with 10000 id increment" do
    @budget_clonemaker.clone_budgets
    @budget_top_18 = Budget.where(f_year: @f_year, parent: nil).first
    @budget_top_19 = @budget_top_18.next_budget
    assert_equal @budget_top_18.id + 10000, @budget_top_19.id
  end

  test "clone clone_stat_zatrs_and_zatrats" do
    @budget_clonemaker.clone_budgets
    @budget_clonemaker.clone_stat_zatrs_and_zatrats
    assert_equal 2, StatZatr.where(f_year: @f_year_next).count
    assert_equal 4, Zatrat.where(f_year: @f_year_next).count
  end

  test "clone normativs and +10000 id increment" do
    @budget_clonemaker.clone_budgets
    @budget_clonemaker.clone_normativs

    assert_equal 3, Normativ.where(f_year: @f_year_next).count

    normativ_in_next_year = @normativ_it_base.normativ_in_next_year
    assert_not_nil normativ_in_next_year
    assert_equal @normativ_it_base.id, normativ_in_next_year.normativ_in_prev_year_id

    # + 10000
    normativ_it_base_18 = normativs(:normativ_it_base)
    normativ_it_base_19 = normativ_it_base_18.normativ_in_next_year
    assert normativ_it_base_19
    assert_equal normativ_it_base_18.id + 10000, normativ_it_base_19.id
  end

  # при клонировании на следующий год:
  # - создается единственная з/п - на январь
  # - з/п на январь равна з/п на декабрь прошлого года
  # - в случае если з/п на декабрь не существует, или 0.0,
  #   то шт. единица не создается
  test "clone_state_units_and_salaries" do
    @budget_clonemaker.clone_budgets
    @budget_clonemaker.clone_state_units_and_salaries
    assert_equal 1, StateUnit.where(f_year: @f_year_next).count
    assert_equal 1, Salary.where(f_year: @f_year_next).count
  end

  test "clone_state_units_and_salaries increment id + 10000" do
    @budget_clonemaker.clone_budgets
    @budget_clonemaker.clone_state_units_and_salaries
    # just one state unit in 19
    state_unit_18 = state_units(:cfo_d_1_user1)
    state_unit_19 = StateUnit.where(f_year: @f_year_next).first
    assert_equal state_unit_18.id + 10_000, state_unit_19.id
  end

  test "clone naklad" do
    @budget_clonemaker.clone_budgets
    @budget_clonemaker.clone_normativs
    @budget_clonemaker.clone_naklad
    assert_equal 6, Naklad.where(f_year: @f_year_next).count
  end

end
