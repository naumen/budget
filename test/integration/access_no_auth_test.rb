require 'test_helper'

class AccessNoAuthTest < ActionDispatch::IntegrationTest

  test "to root redirect" do
    get "/"
    assert_response :redirect
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    assert_select "h1", "Вход"
  end

  test "to budgets redirect" do
    get "/budgets"
    assert_response :redirect
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    assert_select "h1", "Вход"
  end

  test "to normativs redirect" do
    get "/normativs"
    assert_response :redirect
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    assert_select "h1", "Вход"
  end

  test "to sales redirect" do
    get "/sales"
    assert_response :redirect
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    assert_select "h1", "Вход"
  end

end
