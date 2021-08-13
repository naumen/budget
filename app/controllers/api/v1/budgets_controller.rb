module Api
  module V1
    class BudgetsController < ApiController
      def show
        @budget = Budget.find(params[:id])
        @presenter = BudgetPresenter.new(@budget)
      end
    end
  end
end