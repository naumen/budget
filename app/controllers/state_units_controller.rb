class StateUnitsController < ApplicationController
  before_action :set_data, only: [:edit, :create, :update, :destroy, :new]
  before_action :access!, only: [:edit, :create, :update, :destroy, :new]

  def redirect
    st = StateUnit.find(params[:state_unit_id])
    if st.in_current_year?
      # pass
    else
      st = st.get_in_next_year # TODO
    end
    redirect_to "/budgets/#{st.budget_id}?state_unit_id=#{st.id}#state_units"
  end

  def division_compare
    @items = []
    @divisions = {}
  end

  def location_compare
    @items = []
  end

  def not_cloned
    @hide_year_header = true
    @not_cloned = []
  end

  def clone_to_2021
    st = StateUnit.find(params[:state_unit_id])
    if st.f_year == 2020 && st.get_in_next_year.nil?
      st.clone_to_next_year
    end
    redirect_to '/state_units/not_cloned'
  end

  def new
    @state_unit = StateUnit.new
    @state_unit.budget_id = params[:budget_id]
    @locations = Location.active
  end

  def create
    @state_unit = StateUnit.new(state_unit_params)
    @state_unit.f_year = @state_unit.budget.f_year
    @state_unit.rate   = 1.0
    if @state_unit.save
      init_salary(@state_unit)
      redirect_to budget_path(@state_unit.budget, anchor: :state_units), success: 'Шт.единица создана'
    else
      flash.now[:danger] = 'Шт.единица не создана'
      @locations = Location.all
      render :new
    end
  end

  def edit
    @locations = Location.active
  end

  def update
    if @state_unit.update(state_unit_params)
      init_salary(@state_unit)
      redirect_to budget_path(@state_unit.budget, anchor: :state_units), success: 'Шт.единица обновлена'
    else
      @locations = Location.all
      flash.now[:danger] = 'Шт.единица не обновлена'
      render :edit
    end
  end

  def destroy
    if @state_unit.destroy
      redirect_to budget_path(@state_unit.budget, anchor: :state_units), success: 'Шт.единица удалена'
    else
      redirect_to budget_path(@state_unit.budget, anchor: :state_units), danger: 'Шт.единица не удалена'
    end
  end

  private

  def init_salary(state_unit)
    Salary.where(state_unit_id: state_unit.id).destroy_all
    (1..12).to_a.each do |m|
      salary = params[:state_unit][:salaries][m.to_s] rescue 0
      s = Salary.new
      s.state_unit_id = state_unit.id
      s.f_year = state_unit.budget.f_year
      s.month = m
      s.summ = salary.to_f
      s.save
    end
    state_unit.on_update_salary
  end

  def set_data
    @state_unit = StateUnit.find(params[:id]) if params[:id]
    if @state_unit
      @budget = @state_unit.budget
    elsif params[:budget_id]
      @budget = Budget.find(params[:budget_id])
    end

    if @state_unit && @state_unit.f_year != session[:f_year]
      session[:f_year] = @state_unit.f_year
    end

    @salaries = {}
    if @state_unit
      @state_unit.salaries.each do |s|
        @salaries[s.month] = s.summ
      end
    else
      (1..12).to_a.each do |m|
        @salaries[m] = 0.0
      end
    end
    @budgets =[]
    if @current_user.is_admin
      budgets_as_tree = ['new', 'edit', 'create', 'update'].include?(params[:action])
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
  end

  def state_unit_params
    params.require(:state_unit).permit(:budget_id, :position, :division, :location_id)
  end

  def access!
    return true if current_user.is_admin?
    @access = false

    if @budget && @budget.access_for(current_user)
      @access = true
    end

    redirect_to budgets_path, danger: 'Нет доступа' if !@access
  end

end
