class RequestChangeMailer < ApplicationMailer
  default from: 'noreply@budget'

  def self.base_url
    if Rails.env == 'development'
      "http://0.0.0.0:3000"
    else
      "http://budget"
    end
  end

  def init_vars
    @user           = params[:recipient]
    @request_change = params[:request_change]
    @url  = "#{RequestChangeMailer.base_url}/request_changes/#{@request_change.id}"
    els = @user.name.split(' ')
    @user_name = els[1..els.size].join(' ')
  end


  def get_recipient
    _user = params[:recipient]
    _user
  end

  # необходимо согласовать
  def email_confirmation
    init_vars
    mail(to: get_recipient.email, subject: 'Согласование заявления на изменение')
  end

  # бюджет согласован
  def email_confirmed
    init_vars
    mail(to: get_recipient.email, subject: 'Заявление на изменение согласовано')
  end

  # бюджет согласован
  def email_cancelled
    init_vars
    mail(to: get_recipient.email, subject: 'Заявление на изменение отклонено')
  end

end
