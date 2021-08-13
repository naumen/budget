module Api
  module V1
    class StaffItemsController < ApiController
      def index
        @staff_items = StaffItem.all
      end
    end
  end
end