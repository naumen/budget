class UsersRolesController < ApplicationController

  before_action :set_budget, :test_access

  def index
    @users_role = UsersRole.new
    @users = User.active.sorted
    @budget = Budget.find(params[:budget_id].to_i)
  end

  def create
    @users_role = UsersRole.new(users_roles_params)
    
    if @users_role.save
      redirect_to users_roles_path(budget_id: params[:users_role][:budget_id]),  :flash => { :success => "Роль создана" }
    else
      redirect_to users_roles_path(budget_id: params[:users_role][:budget_id]),  :flash => { :danger => "Роль не создана" }
    end
  end

  def destroy
    user_roles = Budget.find(params[:budget_id]).users_role.where(user_id: params[:user_id])
    if user_roles.destroy_all
      redirect_to users_roles_path(budget_id: params[:budget_id]),  :flash => { :success => "Роль удалена" }
    else 
      redirect_to users_roles_path(budget_id: params[:budget_id]), :flash => { :danger => "Ошибка при удалении роли" }
    end
  end

  private

  def users_roles_params
    params.require(:users_role).permit(:budget_id,:user_id, :role)
  end

  def set_budget
    @budget = Budget.find(params[:budget_id])
  end

  def test_access
    return true if current_user.is_admin?
    if @budget.owner && @budget.owner == current_user
      return true
    else
      flash[:danger] = 'Ошибка доступа'
      redirect_to root_path
      return false
    end
  end

end