require 'test_helper'

class AccessAdminTest < ActionDispatch::IntegrationTest

  setup do
    sign_in_as users(:admin)
  end

  test "redirect to budgets list" do
    assert_not_nil session[:user_id]
    assert_response :redirect
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success

    # 6 пунктов меню
    #  Бюджеты
    #  Продажи
    #  Нормативы
    #  Матрица накладных
    #  График
    #  Инвестиции
    #  Настройки
    assert_select(".nav-item", 7)

    assert_select "h2", "Cписок бюджетов"
  end

  test "access to normativs" do
    get normativs_path
    assert_response :success
    assert_select "h2", "Нормативы"
  end

  test "access to sales" do
    get sales_path
    assert_response :success
    assert_select "h2", "Cписок продаж"
  end

  test "access to naklamatr" do
    get naklamatr_path
    assert_response :success
    assert_select "h2", "Распределение накладных по бюджетам"
  end

  test "open budget" do
    budget_d_cfo_1 = budgets(:b_d_cfo_1)
    get budget_path(budget_d_cfo_1)
    assert_response :success
    assert_select ".card-header", budget_d_cfo_1.name
    assert_select "#link_edit_budget"
    assert_select "#link_users_roles"
  end

  test "logout" do
    get logout_path
    assert_response :redirect
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    assert_nil session[:user_id]
    assert_select "h1", "Вход"
  end

end
