class InvestmentProjectsController < ApplicationController
  before_action :initialize_data, only: [:new, :create, :edit, :update]
  before_action :set_investment_project, only: [:show, :edit, :update, :destroy]

  def index
    @investment_projects = InvestmentProject.joins(:from_budget).where("budgets.f_year = #{session[:f_year]}").paginate(:page => params[:page], :per_page => 30)

    if params[:to_budget_id]
      @investment_projects = InvestmentProject.where(to_budget_id: params[:to_budget_id]).paginate(:page => params[:page], :per_page => 30)
      @budget = Budget.find(params[:to_budget_id])
    elsif params[:from_budget_id]
      @investment_projects = InvestmentProject.where(from_budget_id: params[:from_budget_id]).paginate(:page => params[:page], :per_page => 30)
      @budget = Budget.find(params[:from_budget_id])
    end

  end

  def new
    @investment_project = InvestmentProject.new
  end

  def create
    document_id = nil

    if !params['investment_project']['file'].nil?
      document_id = Document.store_file(:file => params['investment_project']['file'])
    end

    _create_params = document_id.nil? ? investment_project_params : investment_project_params.merge({ document_id: document_id })
    @investment_project = InvestmentProject.new(_create_params)
    @investment_project.f_year = @investment_project.from_budget.f_year
    if @investment_project.save
      redirect_to @investment_project, success: 'Инвестпроект успешно создан'
    else
      flash.now[:danger] = 'Инвестпроект не создан'
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    document_id = nil

    if !params['investment_project']['file'].nil?
      document_id = Document.store_file(:file => params['investment_project']['file'])
    end

    if @investment_project.update(document_id.nil? ? investment_project_params : investment_project_params.merge({ document_id: document_id }))
      redirect_to @investment_project, success: 'Инвестпроект успешно обновлен'
    else
      flash.now[:danger] = 'Инвестпроект не обновлен. Проблема с документом'
      render :edit
    end
  end

  def destroy
    @investment_project.destroy
    redirect_to investment_projects_path
  end


  private
    def set_investment_project
      @investment_project = InvestmentProject.find(params[:id])
    end

    def initialize_data
      #@budgets = Budget.where(f_year: session[:f_year])
      @using_budgets   = Budget.where(f_year: session[:f_year], budget_type_id: BudgetSetting.where(settings_params_id: 7).pluck(:budget_setting_type_id)).order(:name)
      @filling_budgets = Budget.where(f_year: session[:f_year], budget_type_id: BudgetSetting.where(settings_params_id: 3).pluck(:budget_setting_type_id)).order(:name)
    end

    def investment_project_params
      params.require(:investment_project).permit(:name, :from_budget_id, :to_budget_id, :currency, :summ, :naudoc_link)
    end
end
