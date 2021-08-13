class BudgetMetriksController < ApplicationController
  before_action :initialize_data, only: [:new, :create, :update, :edit]
  before_action :set_budget_metriks, only: [:edit, :update, :destroy]

  def new
    @budget_metrik = BudgetMetrik.new
  end

  def create
    @budget_metrik = BudgetMetrik.new(budget_metriks_params)
    if @budget_metrik.save
      redirect_to @budget_metrik.budget, success: 'Статья затрат успешно создана'
    else
      flash.now[:danger] = 'Статья затрат не создана'
      render :new
    end
  end
 
  def edit
  end

  def update
    if @budget_metrik.update(budget_metriks_params)
      redirect_to @budget_metrik.budget, success: 'Статья затрат успешно обновлена'
    else
      flash.now[:danger] = 'Статья затрат не обновлена'
      render :edit
    end
  end

  def destroy
    @budget_metrik.destroy
    redirect_to @budget_metrik.budget
  end

  private
    def set_budget_metriks
      @budget_metrik = BudgetMetrik.find(params[:id])
    end

    def initialize_data
      @budgets = @current_user.is_admin ? Budget.where(f_year: session[:f_year]) : @current_user.give_available_budgets(session[:f_year]) unless @current_user.nil?
      @metriks = Metrik.all
    end

    def budget_metriks_params
      params.require(:budget_metrik).permit(:budget_id, :metrik_id, :value)
    end
end