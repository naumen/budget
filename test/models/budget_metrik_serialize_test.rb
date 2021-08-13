require 'test_helper'

class BudgetMetrikSerializeTest < ActiveSupport::TestCase

  def setup
    @budget_main = budgets(:b_d_cfo_1)
    @budget      = budgets(:b_d_cfo_1_fzp)

    @metrik = metriks(:all_state_units)

    # свои метрики
    @own_budget_metriks = { @budget.id => { @metrik.code.to_sym => 10 }}

    # метрики все (свои + рассчитанные дочерние)
    @budget_metriks     = {
      @budget.id      => { @metrik.code.to_sym => 10 },
      @budget_main.id => { @metrik.code.to_sym => 10 }
    }

    BudgetMetrik.serialize_budget_metriks(@own_budget_metriks, @budget_metriks)

    @budget_metrik      = BudgetMetrik.find_by(budget: @budget, metrik: @metrik)
    @budget_main_metrik = BudgetMetrik.find_by(budget: @budget_main, metrik: @metrik)

    @restored_own_budget_metriks, @restored_budget_metriks = BudgetMetrik.restore_budget_metriks
  end

  test "added record(s)" do
    assert_equal 2, BudgetMetrik.count
  end

  # OWN

  test "record metrik exists" do
    assert @budget_metrik
  end

  test "record metrik value_own" do
    assert_equal 10, @budget_metrik.value_own
  end

  test "record metrik value" do
    assert_equal 10, @budget_metrik.value
  end

  # ALL

  test "record metrik budget main exists" do
    assert @budget_main_metrik
  end

  test "record metrik budget main value_own" do
    assert_nil @budget_main_metrik.value_own
  end

  test "record metrik budget main value" do
    assert_equal 10, @budget_main_metrik.value
  end

  # RESTORE
  test "restored values exists" do
    assert @restored_own_budget_metriks
    assert @restored_budget_metriks
  end

  test "restored own value metrik all_state_unit exists" do
    assert @restored_own_budget_metriks[@budget.id][@metrik.code.to_sym]
  end

  test "restored own value metrik all_state_unit value" do
    assert_equal 10, @restored_own_budget_metriks[@budget.id][@metrik.code.to_sym]
  end

  test "restored all value metrik all_state_unit value" do
    assert_equal 10, @restored_budget_metriks[@budget.id][@metrik.code.to_sym]
  end

  test "restored all value metrik all_state_unit value budget main" do
    assert_equal 10, @restored_budget_metriks[@budget_main.id][@metrik.code.to_sym]
  end
end
