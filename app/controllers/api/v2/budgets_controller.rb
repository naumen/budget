module Api
  module V2
    class BudgetsController < ApiController
      def show
        @budget = Budget.find(params[:id])
        @presenter = BudgetPresenter.new(@budget)
      end
    end
  end
end