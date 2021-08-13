class DivisionsController < ApplicationController

  def index
    @divisions = Division.all
  end

  def show
    @division = Division.find(params[:id])
  end

  def _index
    @divisions = []
    @budgets = []
    Division.roots.each do |root|
      Division.each_with_level(root.self_and_descendants) do |division, level|
        @divisions.push(division)
      end
    end
    Budget.roots.where(f_year: session[:f_year]).each do |root|
      Budget.each_with_level(root.self_and_descendants) do |budget, level|
        @budgets.push([(".&nbsp;" * budget.level).html_safe + budget.name, budget.id])
      end
    end
  end

  def update
    @division = Division.find(params[:id])
    if @division.self_and_descendants.update_all(budget_id: params[:division][:budget_id])
      redirect_to divisions_path
    end
  end

  def update_list
    Division.update(params[:division].keys, params[:division].values) ? flash[:success] = 'Подразделения обновились' : flash[:danger] = 'Подразделения не обновились'
    redirect_to divisions_path
  end
end
