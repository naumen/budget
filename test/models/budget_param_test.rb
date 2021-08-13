require 'test_helper'

class BudgetParamTest < ActiveSupport::TestCase
  def setup
    @config = BudgetParam.first
  end

  test "empty" do
     assert_equal '', @config.budgets_report_access
   end

  test "init get_budgets_report_access_users" do
     assert_equal [], @config.get_budgets_report_access_users
   end

  test "budgets_report_access_add_user" do
    user = users(:admin)
    @config.budgets_report_access_add_user(user)
    assert_equal [user], @config.get_budgets_report_access_users
  end

  test "budgets_report_access_del_user" do
    user = users(:admin)
    @config.budgets_report_access_add_user(user)
    assert_equal [user], @config.get_budgets_report_access_users
    
    @config.budgets_report_access_del_user(user)
    assert_equal [], @config.get_budgets_report_access_users
  end

end
