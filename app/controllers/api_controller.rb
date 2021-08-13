class ApiController < ActionController::Base
  force_ssl if: :ssl_configured?

  def ssl_configured?
    !(Rails.env.development? || Rails.env.test? || request.domain == 'localhost')
  end
end
