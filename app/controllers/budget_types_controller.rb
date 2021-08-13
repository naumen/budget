class BudgetTypesController < ApplicationController
  before_action :set_budget_type, only: [:destroy, :edit, :update]

  def index
    @budget_types = BudgetType.all
  end

  def new
    @budget_type = BudgetType.new
  end

  def create
    @budget_type = BudgetType.new(butget_type_params)

    if @budget_type.save
      redirect_to budget_types_path, success: 'Тип бюджета создан'
    else
      flash.now[:danger] = 'Тип бюджета не создан'
      render :new
    end
  end

  def edit;  end

  def update
    if @budget_type.update(butget_type_params)
      redirect_to budget_types_path, success: 'Тип бюджета обновлен'
    else
      flash.now[:danger] = 'Тип бюджета не обновлен'
      render :edit
    end
  end

  def destroy
    if @budget_type.destroy
      redirect_to budget_types_path, success: 'Тип бюджета удален'
    else
      redirect_to budget_types_path, danger: 'Тип бюджета не удален'
    end
  end

  private

  def set_budget_type
    @budget_type = BudgetType.find(params[:id])
  end

  def butget_type_params
    params.require(:budget_type).permit(:name)
  end
end