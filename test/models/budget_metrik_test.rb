require 'test_helper'

class BudgetMetrikTest < ActiveSupport::TestCase

  def setup
    Budget.rebuild!
    f_year = 2018
    @budget_metriks = BudgetMetrik.budget_metriks(f_year)

    @b_top          = budgets(:b_top)
    @b_d_cfo_1_fzp  = budgets(:b_d_cfo_1_fzp)
    @b_d_cfo_1      = budgets(:b_d_cfo_1)
  end

  test "budget_metriks" do
    assert_instance_of Hash, @budget_metriks
  end

  # все шт. единицы включают и Удаленно работающих
  test "budget metriks all state units" do
    assert_equal 2, @budget_metriks[@b_d_cfo_1_fzp.id][:all_state_units]
  end

  # инвестиционные не поднимаются на верх
  test "ancestor budget metriks all state units" do
    parent_budget = @b_d_cfo_1_fzp.parent
    assert_equal 2, @budget_metriks[parent_budget.id][:all_state_units]
  end

  # EKB location
  test "budget metriks location_state_unit_ekb" do
    assert_equal 1, @budget_metriks[@b_d_cfo_1_fzp.id][:location_state_unit_ekb]
  end

  # remote state unit
  test "budget metrik remote state unit" do
    assert_equal 1, @budget_metriks[@b_d_cfo_1_fzp.id][:location_state_unit_external]
  end

  # SALES TOTAL
  test "budget metrik sales" do
    assert_equal 1_000_000.00, @budget_metriks[@b_d_cfo_1.id][:sales_total]
  end

  # fzp
  test "budget metrik fzp" do
    assert_equal 100_000.00, @budget_metriks[@b_d_cfo_1.id][:fzp]
  end

  # location_state_unit_ekb_m
  test "location_state_unit_ekb_m" do
    assert_equal 2, @budget_metriks[@b_d_cfo_1.id][:location_state_unit_ekb_m]
  end

  # fzp_by_location (ekb by default)
  test "fzp_by_location" do
    assert_equal 100_000.00, @budget_metriks[@b_d_cfo_1.id][:fzp_by_location]
  end

  # premii
  test "premii" do
    assert_equal 40_000.00, @budget_metriks[@b_d_cfo_1.id][:premii]
  end

  # fzp and premii
  test "fzp and premii" do
    assert_equal 140_000.00, @budget_metriks[@b_d_cfo_1.id][:fzp_and_premii]
  end

  # metrik top budget
  test "metrik all on top budget" do
    assert_equal 3, @budget_metriks[@b_top.id][:all_state_units]
  end
end
