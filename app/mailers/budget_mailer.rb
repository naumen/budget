class BudgetMailer < ApplicationMailer
  default from: 'noreply@budget'

  def self.base_url
    if Rails.env == 'development'
      "http://0.0.0.0:3000"
    else
      "http://budget"
    end
  end

  def init_vars
    @user      = params[:recipient]
    @budget    = params[:budget]
    @url  = "#{BudgetMailer.base_url}/budgets/#{@budget.id}"
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
    mail(to: get_recipient.email, subject: 'Согласование бюджета')
  end

  # бюджет согласован
  def email_confirmed
    init_vars
    mail(to: get_recipient.email, subject: 'Бюджет Утвержден')
  end

  # бюджет согласован
  def email_cancelled
    init_vars
    mail(to: get_recipient.email, subject: 'Бюджет Отклонен')
  end

end
