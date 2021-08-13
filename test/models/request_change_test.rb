require 'test_helper'

class RequestChangeTest < ActiveSupport::TestCase

  # заявка на изменение - выслана на согласование
  def setup
    @admin = users(:admin)
    @budget_owner     = users(:budget_owner)
    @budget_top_owner = users(:budget_top_owner)
    @fo_user          = users(:fo_user)

    current_user = @admin
    @request_change = request_changes(:one) # b_service

    # budget_owner -> budget_top_owner -> fo_user

    # b_nakladn_management:
    #   parent: b_nakladn
    #   owner: budget_top_owner

    # b_service:
    #   name: Бюджет Сервисного Центра
    #   parent: b_nakladn_management
    #   owner: budget_owner


    @request_change.set_state "На согласовании", current_user
  end

  test "exists and class" do
    assert_instance_of RequestChange, @request_change
  end

  test "budgets owners" do
    assert_equal @request_change.budget.owner, users(:budget_owner)
    assert_equal @request_change.budget.parent.owner, users(:budget_top_owner)
   
  end

  # budget_owner, budget_top_owner, user_fo
  # при посылке на согласование - трем сотрудникам уходит на согласование
  # владельцам бюджетов (текущего и вышестоящего) и сотруднику ФО
  test "init state" do
    assert_equal "На согласовании", @request_change.state
    assert_equal 3, @request_change.request_change_signs.size
  end

  # начальный согласователь
  test "current confirm" do
    assert_equal @budget_owner, @request_change.current_sign.user
    assert_equal false, @request_change.is_all_confirmed?
  end

  # согласовывает первый - переходит на согласование к следующему
  test "do confirm first" do
    @request_change.sign(RequestChangeSign::CONFIRMED, @budget_owner)

    assert_equal false, @request_change.is_all_confirmed?
    assert_equal "На согласовании", @request_change.state
    assert_equal @budget_top_owner, @request_change.current_sign.user
    assert_equal RequestChangeSign::CONFIRMED, @request_change.request_change_signs[0].result
  end

  # согласовывает второй - переходит на согласование к ФО
  test "do confirm second" do
    @request_change.sign(RequestChangeSign::CONFIRMED, @budget_owner)
    @request_change.sign(RequestChangeSign::CONFIRMED, @budget_top_owner)

    assert_equal false, @request_change.is_all_confirmed?
    assert_equal "На согласовании", @request_change.state
    assert_equal @fo_user, @request_change.current_sign.user
    assert_equal RequestChangeSign::CONFIRMED, @request_change.request_change_signs[1].result
  end

  # согласовывает третий - заявка согласована
  test "do confirm third - all confirmed" do
    @request_change.sign(RequestChangeSign::CONFIRMED, @budget_owner)
    @request_change.sign(RequestChangeSign::CONFIRMED, @budget_top_owner)
    @request_change.sign(RequestChangeSign::CONFIRMED, @fo_user)
    assert_equal true, @request_change.is_all_confirmed?
    assert_equal true, @request_change.request_change_histories.map{|h| h.state}.include?("Согласована")
    assert_equal "Обработано", @request_change.state
  end

  # отклоняет первый - переходит на Отклонена
  test "do rejected first" do
    @request_change.sign(RequestChangeSign::REJECTED, @budget_owner)

    assert_equal "Отклонена", @request_change.state
    assert_equal RequestChangeSign::REJECTED, @request_change.request_change_signs[0].result
  end

  # отклонение и на редактирование
  test "do rejected first and edit" do
    @request_change.sign(RequestChangeSign::REJECTED, @budget_owner)
    assert_equal "Отклонена", @request_change.state

    @request_change.set_state "Редактируется", @budget_owner
    assert_equal "Редактируется", @request_change.state
  end

  # отклонение и на редактирование, и на согласование (вторая попытка)
  # владелец бюджета (меньше согласователей) - 2
  test "do rejected first then edit and to confirm" do
    @request_change.sign(RequestChangeSign::REJECTED, @budget_owner)
    @request_change.set_state "Редактируется", @budget_owner
    @request_change.set_state "На согласовании", @budget_owner
    assert_equal "На согласовании", @request_change.state
    assert_equal 2, @request_change.current_signs.size
  end

  test "fot change" do
    fot_change = request_changes(:fot_change)
    assert fot_change
    assert_equal 1, fot_change.request_change_actions.size
    # '{ "state_unit_id": 109958,
    #    "salaries":      [[1,"25300.0"],[2,"25300.0"],[3,"25300.0"],[4,"25300.0"],[5,"233444"],[6,"233444"],[7,"233444"],[8,"233444"],[9,"233444"],[10,"233444"],[11,"233444"],[12,"233444"]],
    #    "selectedStatZatrFot": 12345,
    #    "deltaStatZatrFot":    1665152}'
    assert_equal 109958, fot_change.request_change_actions.first.content['state_unit_id']
    
    fot_delta = 1_665_152
    assert_equal fot_delta, fot_change.request_change_actions.first.content['deltaStatZatrFot']
    assert_equal 12345, fot_change.request_change_actions.first.content['selectedStatZatrFot']

    fot_stat_zatr = stat_zatrs(:fot_stat_zatr)

    # zp before, for - 25300 * 12 = 303600.00

    st_unit = state_units(:cfo_1_fzp_next_user1)
    assert_equal 109958, st_unit.id

    assert_equal 12, st_unit.salaries.size
    assert_equal 303_600.00, st_unit.fzp

    # fot stat zatr
    assert fot_stat_zatr.budget.get_fot_stat_zatr
    assert_equal 2_000_000.00, fot_stat_zatr.budget.fot_value

    # fot_change
    fot_change.proceed(users(:admin))

    # new fot 1,968,752.00
    st_unit = StateUnit.find(109958)
    assert_equal 1_968_752.00, st_unit.fzp

    # fot changed
    assert_equal 2_000_000.00 - fot_delta.to_f, fot_change.budget.fot_value
  end


end
