class SalariesController < ApplicationController

  def new
    @salary = Salary.new
    @state_units = StateUnit.all
  end

  def create
    @salary = Salary.new(salary_params)
    @state_units = StateUnit.all

    if @salary.save
      redirect_to salary_path(@salary.state_unit.id), success: 'Зарплата добавлена'
    else
      flash.now[:danger] = 'Зарплата не добавлена'
      render :new
    end
  end

  def show
    @state_unit = StateUnit.find(params[:id])
    @salaries   = Salary.where(state_unit_id: params[:id])
  end

private
  def salary_params
      params.require(:salary).permit(:state_unit_id, :month, :summ, :f_year)
  end
end
