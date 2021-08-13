class ZatratsController < ApplicationController

  before_action :initialize_data, only: [:new, :create, :edit, :update]
  before_action :set_zatrats, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token


  def report_zp
    f_year = params[:f_year] || "2019"
    ret = ''
    sql = """
     SELECT month, cfos.name as cfo_name, sum(salaries.summ) as mny
     FROM salaries, state_units, cfos, budgets
     WHERE salaries.f_year=#{f_year}
       and budgets.id = state_units.budget_id
       and budgets.cfo_id = cfos.id
       and salaries.state_unit_id=state_units.id
     GROUP BY budgets.cfo_id, salaries.month
     ORDER BY salaries.month, budgets.cfo_id
     """

    items = Zatrat.connection.select_all(sql)
    items.each do |item|
      row = []
      row << item['month']
      row << item['cfo_name']
      row << item['mny']
      ret << row.join("\t") << "\n"
    end
    render plain: ret
  end

  def report
    f_year = params[:f_year] || "2019"
    ret = ''
    sql = """
    select
    	month,
    	cfos.name as cfo_name,
    	spr_stat_zatrs.name as spr_name,
    	sum(summ) as mny
    from
    	zatrats,
    	stat_zatrs,
    	spr_stat_zatrs,
    	budgets,
    	cfos
    where
    	zatrats.stat_zatr_id = stat_zatrs.id
    	and zatrats.f_year = #{f_year}
    	and stat_zatrs.spr_stat_zatrs_id = spr_stat_zatrs.id
    	and stat_zatrs.budget_id = budgets.id
    	and budgets.cfo_id = cfos.id
    group by
    	month,
    	budgets.cfo_id,
    	stat_zatrs.spr_stat_zatrs_id
    """
    items = Zatrat.connection.select_all(sql)
    items.each do |item|
      row = []
      row << item['month']
      row << item['cfo_name']
      row << item['spr_name']
      row << item['mny']
      ret << row.join("\t") << "\n"
    end
    render plain: ret
  end


  def index
    @zatrats = Zatrat.paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @zatrat = Zatrat.new
    @zatrat.stat_zatr_id = params[:stat_zatr_id]
  end

  def create
    @zatrat = Zatrat.new(zatrats_params)
    @zatrat.f_year = @zatrat.stat_zatr.f_year
    if @zatrat.save
      StatZatr.calculate_zatrats(@zatrat.stat_zatr)
      redirect_to @zatrat.stat_zatr, success: 'Статья затрат успешно создана'
    else
      flash.now[:danger] = 'Статья затрат не создана'
      render :new
    end
  end

  def edit
  end

  def update
    if @zatrat.update(zatrats_params)
      StatZatr.calculate_zatrats(@zatrat.stat_zatr)
      redirect_to @zatrat.stat_zatr, success: 'Статья затрат успешно обновлена'
    else
      flash.now[:danger] = 'Статья затрат не обновлена'
      render :edit
    end
  end

  def destroy
    if @zatrat.destroy
      redirect_to @zatrat.stat_zatr, success: 'Затрата успешно удалена'
    else
      flash.now[:danger] = 'Произошла ошибка при удалении'
    end
  end

  def destroy_zatrats
    unless params[:zatrats_id].nil?
      if Zatrat.delete(params[:zatrats_id])
        redirect_to stat_zatr_path(params[:stat_zatr_id]), success: 'Затрата успешно удалена'
      else
        flash.now[:danger] = 'Произошла ошибка при удалении'
      end
    end
  end

  private
    def set_zatrats
      @zatrat = Zatrat.find(params[:id])
    end

    def initialize_data
      @budgets = @current_user.is_admin ? Budget.where(f_year: session[:f_year]) : @current_user.give_available_budgets(session[:f_year]) unless @current_user.nil?
      @stat_zatrs = StatZatr.all
    end

    def zatrats_params
      params.require(:zatrat).permit(:stat_zatr_id, :month, :month_to, :summ, :nal_beznal)
    end
end
