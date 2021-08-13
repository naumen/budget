class RepaymentLoansController < ApplicationController

  before_action :magic_with_budget_id, only: [:create]

  def create
    @repayment_loan = RepaymentLoan.new(repayment_loans_params)
    if @repayment_loan.save
      redirect_to invest_loans_path + "/#{params[:repayment_loan][:invest_loan_id]}",  :flash => { :success => 'График добавлен' }
    else
      redirect_to invest_loans_path + "/#{params[:repayment_loan][:invest_loan_id]}",  :flash => { :danger => 'Ошибка добавления графика' }
    end
  end

  def destroy
    @repayment_loan = RepaymentLoan.find(params[:id])
    if @repayment_loan.destroy
      redirect_to invest_loans_path + "/#{params[:invest_loan_id]}",  :flash => { :success => 'График удален' }
    else
      redirect_to invest_loans_path + "/#{params[:invest_loan_id]}",  :flash => { :danger => 'График не удален' }
    end
  end

  private
    def magic_with_budget_id
      from_budget = Budget.find(params[:repayment_loan][:from_budget_id].to_i)
      to_budget = Budget.find(params[:repayment_loan][:to_budget_id].to_i)
      f_year = params[:repayment_loan][:f_year].to_i

      new_from_budget = Budget.give_me_budget_in_year(from_budget, f_year)
      new_to_budget = Budget.give_me_budget_in_year(to_budget, f_year)

      if new_to_budget.nil? || new_from_budget.nil?
        params[:repayment_loan][:from_budget_id] = nil
        params[:repayment_loan][:to_budget_id] = nil
      else
        params[:repayment_loan][:from_budget_id] = new_from_budget.id
        params[:repayment_loan][:to_budget_id] = new_to_budget.id
      end
    end

    def repayment_loans_params
      params.require(:repayment_loan).permit(:invest_loan_id, :fin_year, :summ, :from_budget_id, :to_budget_id)
    end
end
