require 'test_helper'

class AccessBudgetEditorTest < ActionDispatch::IntegrationTest

  setup do
    Budget.rebuild!
    sign_in_as users(:budget_editor)
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

  test "no access to naklamatr" do
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
    assert_select "#link_new_sale"
    assert_select "#link_new_stat_zatr"
    assert_select "#link_new_childbudget"

    assert_select "#link_users_roles", {:count=>0}
  end

  test "no access to other budget" do
    b_nakladn = budgets(:b_nakladn)
    get budget_path(b_nakladn)
    assert_response :redirect
    assert_redirected_to budgets_url
  end

  test "access to nested" do
    b_d_cfo_1_fzp = budgets(:b_d_cfo_1_fzp)
    get budget_path(b_d_cfo_1_fzp)

    assert_response :success

    assert_select ".card-header", b_d_cfo_1_fzp.name
    assert_select "#link_edit_budget"
    assert_select "#link_new_sale"
    assert_select "#link_new_stat_zatr"
    assert_select "#link_new_childbudget"
    assert_select "#link_users_roles", {:count=>0}
  end

#   test "open nested budget"
#


end
