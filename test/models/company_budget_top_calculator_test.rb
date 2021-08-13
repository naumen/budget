require 'test_helper'

class CompanyBudgetTopCalculatorTest < ActiveSupport::TestCase

  def setup
    Budget.rebuild!

    f_year = 2018

    @budget_metrik_calculator = BudgetMetrikCalculator.new(f_year)
    @budget_metrik_calculator.calculate

    @b_top = budgets(:b_top)

    @cb_calc = CompanyBudgetCalculator.new(@budget_metrik_calculator, @b_top)
    @company_budget = @cb_calc.calculate_company_budget
    @budgets_info = @cb_calc.budgets_info
  end

  test "budget top in is sales" do
    assert_equal 1_000_000.00, @budgets_info[@b_top.id].in.itogo.to_f
  end

end
