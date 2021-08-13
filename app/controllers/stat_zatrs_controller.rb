class StatZatrsController < ApplicationController

  before_action :initialize_data, only: [:new, :create, :edit, :update]
  before_action :set_stat_zatr, only: [:show, :edit, :update, :destroy, :destroy_all_zatrats]
  skip_before_action :verify_authenticity_token

  def index
    @stat_zatrs = StatZatr.includes(:budget).where(budgets: { f_year: session[:f_year]}).paginate(:page => params[:page], :per_page => 30)

    if params[:budget_id]
      @stat_zatrs = StatZatr.includes(:budget).where(budgets: { id: params[:budget_id]}).paginate(:page => params[:page], :per_page => 30)
      @budget = Budget.find(params[:budget_id])
    end
  end

  def new
    @stat_zatr = StatZatr.new
    @stat_zatr.budget_id = params[:budget_id] if params[:budget_id].to_i > 0
  end

  def create
    @stat_zatr = StatZatr.new(stat_zatr_params)
    budget = Budget.find(stat_zatr_params[:budget_id])
    @stat_zatr.f_year = budget.f_year

    if @stat_zatr.save
      redirect_to @stat_zatr, success: 'Статья затрат успешно создана'
    else
      flash.now[:danger] = 'Статья затрат не создана'
      render :new
    end
  end

  def show
    @zatrats = Zatrat.where("stat_zatr_id=?", @stat_zatr.id).order('month')
    @budget = @stat_zatr.budget
  end

  def edit
  end

  def update
    if @stat_zatr.update(stat_zatr_params)
      redirect_to @stat_zatr, success: 'Статья затрат успешно обновлена'
    else
      flash.now[:danger] = 'Статья затрат не обновлена'
      render :edit
    end
  end

  def create_fix_zatrats
    month = params["zatrat"]["month_from"].to_i
    if month <= params["zatrat"]["month_to"].to_i && month > 0
      stat_zatr = StatZatr.find(params[:zatrat][:stat_zatr_id])

      while month <= params["zatrat"]["month_to"].to_i
        zatrat = Zatrat.new(
          stat_zatr_id: stat_zatr.id,
          month: month,
          f_year: stat_zatr.f_year,
          summ: params["zatrat"]["summ"],
          nal_beznal: params["zatrat"]["nal_beznal"]
        )
        if zatrat.save
          puts "сохранили месяц #{month} c суммой #{params['zatrat']['summ']}"
        end
        month += 1
      end
    end

    StatZatr.calculate_zatrats(zatrat.stat_zatr)
    redirect_to stat_zatr_path(params["zatrat"]["stat_zatr_id"]), :flash => { :danger => "Создано!" }
  end

  def destroy
    @stat_zatr.destroy
    redirect_to @stat_zatr.budget
  end

  private

  def set_stat_zatr
    @stat_zatr = StatZatr.find(params[:id])
  end

  def initialize_data
    @budgets = @current_user.is_admin ? Budget.where(f_year: session[:f_year]) : @current_user.give_available_budgets(session[:f_year]) unless @current_user.nil?
  end

  def stat_zatr_params
    params.require(:stat_zatr).permit(:budget_id, :spr_stat_zatrs_id, :name)
  end
end
