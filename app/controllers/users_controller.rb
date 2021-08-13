class UsersController < ApplicationController
  def login
    if session[:user_id]
      redirect_to root_path
      return
    end
  end

  def index
  end

  def authorization
    login = params[:session][:login].downcase
    pwd   = params[:session][:password]
    user = User.find_by(login: login)
    if user && User.authenticate(login, pwd)
      log_in(user)
      previous_path = session[:previous_url]
      session[:previous_url] = nil
      redirect_to (previous_path || root_path)
    else
      flash.now[:danger] = 'Неверный логин или пароль'
      render :login
    end
  end

  def logout
    log_out
    redirect_to login_path
  end

  def secure?
    false
  end

end
