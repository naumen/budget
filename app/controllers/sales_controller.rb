class SalesController < ApplicationController

  before_action :initialize_data, only: [:new, :create, :edit, :update]
  before_action :set_sale, only: [:show, :edit, :update, :destroy]

  def index
    @sales = Sale.includes(:budget).where(budgets: { f_year: session[:f_year]}).paginate(:page => params[:page], :per_page => 30)

    if params[:budget_id]
      @sales = Sale.includes(:budget).where(budgets: { id: params[:budget_id]}).paginate(:page => params[:page], :per_page => 30)
      @budget = Budget.find(params[:budget_id])
    end
  end

  def new
    @sale = Sale.new
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.f_year = @sale.budget.f_year
    if @sale.save
      redirect_to @sale, success: 'Продажа успешно создана'
    else
      flash.now[:danger] = 'Продажа не создана'
      render :new
    end
  end

  def show
    @budget = Budget.find(@sale.budget_id)
    @sales_channel = SaleChannel.find(@sale.sale_channel_id)
    @user = User.find(@sale.user_id)
  end

  def edit
  end

  def update
    if @sale.update(sale_params)
      redirect_to @sale, success: 'Продажа успешно обновлена'
    else
      flash.now[:danger] = 'Продажа не обновлена'
      render :edit
    end
  end

  def destroy
    @sale.destroy
    redirect_to @sale.budget
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def initialize_data
    @budgets =[]
    if @current_user.is_admin
      budgets_as_tree = ['new', 'edit', 'update'].include?(params[:action])
      if budgets_as_tree
        root = if session[:f_year].to_i == 2021
                  Budget.find(100001)
               elsif session[:f_year].to_i == 2020
                  Budget.find(90001)
               elsif session[:f_year].to_i == 2019
                  Budget.find(80001)
               else
                  Budget.find(70001)
               end
        Budget.each_with_level(root.self_and_descendants) do |b|
          @budgets << b
        end
      else
        @budgets = Budget.where(f_year: session[:f_year])
      end
    else
      @budgets = @current_user.give_available_budgets(session[:f_year]) unless @current_user.nil?
    end

    @cfos = Cfo.where(archived_date: nil).sorted
    @sales_channels = SaleChannel.where(f_year: session[:f_year]).only_actual
    @users = User.all.sorted
  end

  def sale_params
    params.require(:sale).permit(:budget_id, :cfo_id, :sale_channel_id, :user_id, :year, :quarter, :summ, :currency, :name)
  end

  def allow?(user)
    user.is_admin?
  end

end
