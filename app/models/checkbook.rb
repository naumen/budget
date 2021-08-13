class Checkbook < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :ticket_database

  def self.url
    "http://checks"
  end

  def self.checkbooks(budget_id)
    ret = []

    budget = Budget.find(budget_id)

    # checks
    sql = """
      select
        checkbook_id,
        count(*) as cnt,
        sum(checks.summ) as summa
      from
        checks,
        checkbooks
      where
        checkbooks.budget_id = #{budget_id}
        and checks.checkbook_id = checkbooks.id
        and checks.archive_date is null
        and date_format(checks.d_create, '%Y') = '#{budget.f_year}'
      group by checkbook_id
    """

    check_info = {}
    Checkbook.connection.select_all(sql).each do |row|
      checkbook_id = row['checkbook_id'].to_i
      check_info[checkbook_id] = {}
      check_info[checkbook_id][:cnt]   = row['cnt'].to_i
      check_info[checkbook_id][:summa] = row['summa'].to_f
    end
    


    sql = "select * from checkbooks where archive_date is null and budget_id=#{budget_id}"
    Checkbook.connection.select_all(sql).each do |row|
      checkbook_id = row['id'].to_i

      _check_info = check_info[checkbook_id] rescue nil
      info = {}
      info['id'] = row['id']
      info['name'] = row['name']
      info['limit'] = row['limit'].to_f
      info['check_cnt']  = _check_info ? _check_info[:cnt] : 0
      info['check_summ'] = _check_info ? _check_info[:summa] : 0.0
      info['rest'] = info['limit'] - info['check_summ']
      ret << info
    end
    ret
  end

end
