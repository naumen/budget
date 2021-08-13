class InvestLoansController < ApplicationController
  before_action :set_invest_loan, only: [:show, :edit, :update, :destroy]
  before_action :initialize_data, only: [:new, :create, :edit, :update, :naklamatr]

  def index
    @invest_loans = InvestLoan.paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @invest_loan = InvestLoan.new
  end

  def create
    document_id = nil

    if !params['invest_loan']['file'].nil?
      document_id = Document.store_file(:file => params['invest_loan']['file'])
    end

    _create_params = document_id.nil? ? invest_loan_params : invest_loan_params.merge({ document_id: document_id })
    @invest_loan = InvestLoan.new(_create_params)
    if @invest_loan.save
      redirect_to @invest_loan, success: 'Инвест займ успешно создан'
    else
      flash.now[:danger] = 'Инвест займ не создан'
      render :new
    end
  end

  def show
    @repayment_loan = RepaymentLoan.new
  end

  def edit
  end

  def update
    document_id = nil

    if !params['invest_loan']['file'].nil?
      document_id = Document.store_file(:file => params['invest_loan']['file'])
    end

    _update_params = document_id.nil? ? invest_loan_params : invest_loan_params.merge({ document_id: document_id })
    if @invest_loan.update(_update_params)
      redirect_to @invest_loan, success: 'Инвестпроект успешно обновлен'
    else
      flash.now[:danger] = 'Инвест займ не обновлен'
      render :new
    end
  end

  def destroy
    if @invest_loan.destroy
      redirect_to budgets_path, success: 'Инвест займ успешно удален'
    else
      flash.now[:danger] = 'Инвест займ не удален'
    end
  end

  private
    def set_invest_loan
      @invest_loan = InvestLoan.find(params[:id])
    end

    def initialize_data
      #@budgets = Budget.where(f_year: session[:f_year])
      @using_budgets   = Budget.where(f_year: session[:f_year], budget_type_id: BudgetSetting.where(settings_params_id: 8).pluck(:budget_setting_type_id)).order(:name)
      @filling_budgets = Budget.where(f_year: session[:f_year], budget_type_id: BudgetSetting.where(settings_params_id: 4).pluck(:budget_setting_type_id)).order(:name)
    end

    def invest_loan_params
      params.require(:invest_loan).permit(:name, :use_budget_id, :credit_budget_id, :currency, :summ, :interest_rate)
    end
end
