require 'test_helper'

class AccessBudgetOwnerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in_as users(:budget_owner)
  end

  test "redirect to budgets list" do
    assert_not_nil session[:user_id]
    assert_response :redirect
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success

    # 1 пункт меню
    #  Бюджеты
    assert_select(".nav-item", 1)

    assert_select "h2", "Cписок бюджетов"
    assert_select "h3", {:count=>0, :text=>"Список справочников:"}
  end

  test "no access to normativs" do
    get normativs_path
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "no access to sales" do
    get sales_path
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "access to naklamatr" do
    get naklamatr_path
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "open budget" do
    budget_d_cfo_1 = budgets(:b_d_cfo_1)
    get budget_path(budget_d_cfo_1)
    assert_response :success
    assert_select ".card-header", budget_d_cfo_1.name
    assert_select "#link_edit_budget"
    assert_select "#link_users_roles"
  end

end
