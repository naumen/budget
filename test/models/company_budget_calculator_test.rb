require 'test_helper'

class CompanyBudgetCalculatorTest < ActiveSupport::TestCase

  def setup
    Budget.rebuild!

    f_year = 2018

#     # test with cloned budget to 2019
#     @budget_clonemaker = BudgetClonemaker.new(f_year)
#     @budget_clonemaker.clone_all

    @budget_metrik_calculator = BudgetMetrikCalculator.new(f_year)
    @budget_metrik_calculator.calculate

    @b_d_cfo_1 = budgets(:b_d_cfo_1)

    @cb_calc = CompanyBudgetCalculator.new(@budget_metrik_calculator, @b_d_cfo_1)

    @company_budget = @cb_calc.calculate_company_budget
    @budgets_info = @cb_calc.budgets_info

    @b_profit_distribution = budgets(:b_profit_distribution)
    @b_d_cfo_1_fzp = budgets(:b_d_cfo_1_fzp)
    @b_invest      = budgets(:b_invest)
    @b_it          = budgets(:b_it)

    @normativ_service = normativs(:normativ_service)
  end

  test "budgets info" do
    assert @budgets_info
  end
  
  test "budgets info b_d_cfo_1" do
    assert @budgets_info[@b_d_cfo_1.id]
  end

  test "budgets info b_d_cfo_1 in own" do
    assert_equal 1_000_000.00, @budgets_info[@b_d_cfo_1.id].in.own.sales
  end

  test "budgets info b_d_cfo_1 out own zatratas" do
    # 1_000.00 + 10_000.00 + 20_000.00 + 20_000.00
    cfo_zatrats = 51_000.00
    assert_equal cfo_zatrats, @budgets_info[@b_d_cfo_1.id].out.own.zatratas
  end

  test "budgets info b_d_cfo_1 out sub salary" do
    assert_equal 100_000.00, @budgets_info[@b_d_cfo_1.id].out.sub.salary
  end

  test "budgets info b_d_cfo_1 out itogo" do
    itogo = 48100.0 * 2.0 + 300.0 + 51_000.00 + 100_000.00 + 222.0 / 2
    invest = 48100.0 * 1.0
    itogo += invest

    assert_equal itogo, @budgets_info[@b_d_cfo_1.id].out.itogo.to_f
  end

  test "budgets info b_d_cfo_1 out sub nakladn" do
    # only invest sub
    assert_equal 0.0, @budgets_info[@b_d_cfo_1.id].out.sub.nakladn.to_f
  end

  test "budgets info b_d_cfo_1 out sub invest" do
    # invest sub
    assert_equal 48100.0, @budgets_info[@b_d_cfo_1.id].out.sub.invest.to_f
  end

  test "budget calculactor exists" do
    assert_instance_of CompanyBudgetCalculator, @cb_calc
  end

  test "result is hash" do
    assert_instance_of Hash, @company_budget
  end

  # { budget_id1:
  #     in:
  #       nakladn:
  #       sales:
  #       invest:
  #       itogo:
  #     out:
  #       nakladn:
  #       salary:
  #       nakladn_details: [ nakladn_meta1, ... ]
  #   budget_id2:
  #     in:
  #     out:
  #   ... }
  test "b_d_cfo_1 out nakladn test" do
    # metrik + weight
    itogo = 48100.0 * 2.0 + 300.0 + 222.0 / 2
    assert_equal itogo, @company_budget[@b_d_cfo_1.id][:out][:nakladn].to_f
  end

  test "b_d_cfo_1 out itogo" do
    # metrik + weight + salaries + zatratas
    itogo = 48100.0 * 2.0 + 300.0 + 51_000.00 + 1.0 / 2.0 * 222
    assert_equal itogo, @company_budget[@b_d_cfo_1.id][:out][:itogo].to_f
  end

  test "b_it in nakladn test" do
    assert_equal 48100.0 * (2.0 + 1.0), @company_budget[@b_it.id][:in][:nakladn].to_f
  end

  test "invest budget count" do
    assert_equal 1, @budget_metrik_calculator.invest_budget_ids.size
  end

  test "invest budget eq" do
    assert_equal @b_invest.id, @budget_metrik_calculator.invest_budget_ids[0]
  end

  test "b_d_cfo_1 nakladn meta" do
    assert_equal 3, @company_budget[@b_d_cfo_1.id][:out][:nakladn_details].size
  end

  test "CompanyBudgetCalculator contain normativs_by_weight" do
    assert @cb_calc.normativs_by_weight
  end

  test "normativs_by_weight normativ_service" do
    assert @cb_calc.normativs_by_weight[@normativ_service.id]
  end

  test "normativs_by_weight normativ_service summ" do
    assert_equal 10.0, @cb_calc.normativs_by_weight[@normativ_service.id].to_f
  end

  test "b_d_cfo_1 sale incoming" do
    assert_equal 1_000_000.00, @company_budget[@b_d_cfo_1.id][:in][:sales].to_f
  end

  test "b_d_cfo_1_fzp salary out" do
    assert_equal 100_000.00, @company_budget[@b_d_cfo_1_fzp.id][:out][:salary].to_f
  end

  test "b_d_cfo_1 out zatratas" do
    # 1_000.00 + 10_000.00 + 20_000.00 + 20_000.00
    assert_equal 51_000.00, @company_budget[@b_d_cfo_1.id][:out][:zatratas].to_f
  end

  test "b_invest in invest" do
    assert_equal 2_000.00, @company_budget[@b_invest.id][:in][:invest].to_f
  end

  test "b_profit_distribution out invest" do
    assert_equal 2_000.00, @company_budget[@b_profit_distribution.id][:out][:invest].to_f
  end

  test "b_d_cfo_1 in nds" do
    # 8 %
    assert_equal 80_000.00, @company_budget[@b_d_cfo_1.id][:in][:nds].to_f
  end

  test "b_d_cfo_1 budget_info in own nds" do
    # 8 %
    assert_equal 80_000.00, @budgets_info[@b_d_cfo_1.id][:in][:nds].to_f
  end

end
