class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?

  helper_method :current_user, :logged_in?

  before_action :authenticate, :current_confirmation

#   before_action :current_user
#   before_action :get_fin_year
#   before_action :get_breadcrumb

  protect_from_forgery prepend: true
  add_flash_types :success, :danger, :info

  include ApplicationHelper

  def secure?
    true
  end

  def allow?(user)
    true
  end

  def current_confirmation
    if @current_user
      @current_confirmation = BudgetSign.current_confirmation
      @current_request_confirmation = RequestChange.current_confirmation
      @user_wait_confirmation = @current_confirmation[@current_user.id] || []
      @user_wait_request_confirmation = @current_request_confirmation[@current_user.id] || []
    end
    @user_wait_confirmation ||= []
  end

  def authenticate
    if secure?
      if session[:user_id]
        @current_user ||= User.find_by(id: session[:user_id])
        if allow?(@current_user)
          return true
        else
          redirect_to root_path
          return false
        end
      else
        session[:previous_url] = request.fullpath
        redirect_to login_path
        return false
      end
    end
  end

  def log_in(user)
    session[:user_id] = user.id
    session[:f_year]  = Time.now.year
    current_user
  end

  def current_user
    session[:f_year] = params[:f_year].to_i if !params[:f_year].nil?
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    session.delete(:f_year)
    @current_user = nil
  end


  def ssl_configured?
    !(Rails.env.development? || Rails.env.test? || request.domain == 'localhost')
  end
end
