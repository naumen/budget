require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/reporters'
reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
end

module SignInHelper
  def sign_in_as(user)
    post login_url(session: { login: user.login, password: "Budget"})
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end