require 'test_helper'

class BudgetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    Budget.rebuild!
    @b_top = budgets(:b_top)
      @b_d_cfos = budgets(:b_d_cfos)
        @b_d_cfo_1 = budgets(:b_d_cfo_1)
          @b_d_cfo_1_fzp = budgets(:b_d_cfo_1_fzp)
        @b_invest = budgets(:b_invest)
       @b_nakladn = budgets(:b_nakladn)
        @b_nakladn_management = budgets(:b_nakladn_management)
          @b_it  = budgets(:b_it)

    @state_unit_cfo_d_1_user1  = state_units(:cfo_d_1_user1)
  end

  test "top budget" do
    assert_equal @b_top, Budget.top_budget(2018)
  end

  test "salary 2 cnt" do
    assert_equal 2, @state_unit_cfo_d_1_user1.salaries.size
  end

  test "test valid" do
    assert_equal "Бюджет компании", @b_top.name

    assert_equal "Бюджеты центров прибыли", @b_d_cfos.name
    assert_equal @b_top, @b_d_cfos.parent
    assert_equal "Бюджет ЦФО 1", @b_d_cfo_1.name
    assert_equal @b_d_cfos, @b_d_cfo_1.parent
    assert_equal "Бюджет ЦФО 1 ФЗП", @b_d_cfo_1_fzp.name
    assert_equal @b_d_cfo_1, @b_d_cfo_1_fzp.parent

    assert_equal "Инвестиционный", @b_invest.name
    assert_equal @b_d_cfo_1, @b_invest.parent
    assert_equal "Инвестиционный компании", @b_invest.budget_type.name

#    invest_company


    assert_equal "Накладные расходы", @b_nakladn.name
    assert_equal @b_top, @b_nakladn.parent

    assert_equal "Накладные управления компанией", @b_nakladn_management.name
    assert_equal @b_nakladn, @b_nakladn_management.parent

    assert_equal "Службы информационных технологий", @b_it.name
    assert_equal @b_nakladn_management, @b_it.parent


  end

  test "state units fzp" do
    assert_equal 2, @b_d_cfo_1_fzp.state_units.size
  end

  test "ancestors" do
    assert_equal 3, @b_d_cfo_1_fzp.ancestors.size
  end

  test "budget normativs" do
    assert_equal 1, @b_it.normativs.size
  end

  # set fot
  test "set fot" do
    budget = budgets(:b_d_cfo_1_fzp_next)
    assert_equal 0.0, budget.fot_value

    assert_equal 0, FotLog.count
    

    budget.set_fot_value(1234.00)
    assert_equal 1234.00, budget.fot_value
    assert_equal 1, FotLog.count
  end


end
