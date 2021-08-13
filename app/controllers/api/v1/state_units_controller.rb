module Api
  module V1
    class StateUnitsController < ApiController
      def index
        cfo_id = params[:cfo_id]
        location_id = params[:location_id]
        @state_units = StateUnit.free(cfo_id, location_id)
      end

      def by_staff_item
        staff_item_id = params[:staff_item_id]
        f_year        = params[:f_year]
        items = StateUnit.where(staff_item_id: staff_item_id, f_year: f_year).all
        if items.size == 1
          @state_unit = items[0]
        else
          render plain: '{}'
        end
      end

      def bind
        budget_staff_id = params[:budget_staff_item_id]
        staff_item_id = params[:staff_item_id]

        state_unit = StateUnit.find(budget_staff_id) rescue nil
        if state_unit.nil?
          @result = "error"
        else
          @result = state_unit.bind_to_staff_item(staff_item_id)
        end
      end

    end
  end
end