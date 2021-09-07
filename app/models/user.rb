# Model User
class User < ApplicationRecord
  has_many :users_role, :class_name => 'UsersRole'
  has_many :budgets, through: :users_role

  belongs_to :stat_unit, class_name: 'StatUnit', foreign_key: 'user_id', optional: true

  has_many :budget, foreign_key: 'user_id'

  scope :sorted, -> { order(:name) }
  scope :active, -> { where.not( login: [nil, '']) }

  def employment_term_text
    if self.employment_term.blank?
      "тип сотрудничества не указан"
    elsif self.employment_term == 'labour'
      "штатный сотрудник"
    elsif self.employment_term == 'outsource'
      "временный подрядчик"
    else
      "тип сотрудничества: #{self.employment_term}"
    end
  end

  def is_superadmin?
    [].include?(login)
  end

  def self.get_user_terms
  end

  def self.get_cnt(url, login=nil, pwd=nil)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    if url.starts_with?('https://')
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    req = Net::HTTP::Get.new(uri.request_uri)
    req.basic_auth(login, pwd) if login
    response = http.request(req)
    result = response.body.force_encoding('utf-8')

    result
  end

  def self.user_salaries
    f_year  = Date.today.year
    f_month = Date.today.month
    ret = {}
    StateUnit.where(f_year: f_year).where.not(user_id: nil).each do |state_unit|
      salary = state_unit.salaries.where(month: f_month).first.summ
      ret[state_unit.user_id] = [salary, state_unit.id, state_unit.budget_id]
    end
    ret
  end

  def self.get_content_by_url(url)
    require 'open-uri'
    open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
  end

  def self.hr_base
    if Rails.env == 'production'
      "http://hr"
    else
      "http://0.0.0.0:4007"
    end
  end

  def self.get_fo_user
    User.find_by_login("FO_USER")
  end

  def hr_manager?
    ['HR_MANAGER_LOGINS'].include?(login)
  end

  def archive_date
    nil
  end

  def l_name
    name.split(' ')[0] rescue ''
  end

  def f_name
    name.split(' ')[1] rescue ''
  end

  def s_name
    name.split(' ')[2] rescue ''
  end

  def access_to_all_confirmations?
    [].include?(login)
  end

  def email
    "#{login}@domain" # TODO
  end

  def available_budgets(f_year, include_reader=false)
    nested_budgets = []
    accessable_budgets = []
    accessable_budgets += self.owned_budgets(f_year)
    accessable_budgets += self.editor_of_budgets(f_year)
    accessable_budgets += self.reader_of_budgets(f_year) if include_reader
    accessable_budgets.uniq!
    accessable_budgets.each do |b|
      nested_budgets += b.self_and_descendants
    end
    nested_budgets.uniq

    budgets = []
    Budget.where(f_year: f_year).each do |budget|
      budgets.push(budget) if nested_budgets.include?(budget)
    end
    budgets.delete_if{|b| b.archived}
    budgets    
  end

  def editor_of_budgets(f_year)
    self.users_role.select{ |r| r.role == "editor"}.map{|r| r.budget}.select{|b| b.f_year == f_year}
  end

  def reader_of_budgets(f_year)
    self.users_role.select{ |r| r.role == "reader"}.map{|r| r.budget}.select{|b| b.f_year == f_year}
  end

  def owned_budgets(f_year)
    Budget.where(f_year: f_year, user_id: self.id)
  end

  def give_available_budgets(f_year)
    return self.available_budgets(f_year)
  end

  def any_budget_owner?(f_year=2019)
    Budget.where( f_year: f_year, user_id: self.id).all.size > 0
  end

  def self.authenticate(login, password)
    if Rails.env == 'production'
      return User.ldap_auth(login, password)
    else
      password == ENV.fetch('DEFAULT_ADMIN_DEVELOPMENT_PASS') { 'Budget' }
    end
  end

  def self.import
  end

  private

  def self.ldap_auth(login, passwd)
    config = YAML.load_file("#{Rails.root}/config/settings.yml")
    host = "LDAP_HOST"
    port = 636
    auth = {
      :method => :simple,
      :username => "",
      :password => config['ldap']['pwd']
    }

    ldap = Net::LDAP.new :host => host,
                         :port => port,
                         :auth => auth,
                         :encryption => { :method => :simple_tls }

    filter = Net::LDAP::Filter.eq( "uid", login )
    treebase = ""
    attrs = ldap.search( :base => treebase, :filter => filter )

    if attrs.length == 1
      name = attrs[0].dn
      auth[:username] = name
      auth[:password] = passwd
      if ldap.bind
        is_auth = true
      else
        is_auth = false
      end
    else
      is_auth = false
    end
    return is_auth
  end

end
