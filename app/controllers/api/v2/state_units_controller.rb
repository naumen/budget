module Api
  module V2
    class StateUnitsController < ApiController
      def index
        @state_units = StateUnit.free_all
      end

      def bind_unbind_v2
        do_action = params["do_action"] # "bind" | "unbind"
        state_unit_ids = params["ids"]

        ret = {}

        if state_unit_ids.empty?
          ret["result"] = "error"
          ret["errors"] = [{ id: nil, message: "empty ids"}]
          render json: ret
          return
        end

        not_found_ids = []
        state_units = []
        state_unit_ids.each do |state_unit_id|
          state_unit = StateUnit.where(id: state_unit_id).first
          if state_unit.nil?
            not_found_ids << state_unit_id
          else
            state_units << state_unit
          end
        end

        if not_found_ids.empty?
          ActiveRecord::Base.transaction do
            state_units.each do |state_unit|
              if do_action == 'bind'
                state_unit.bind!
              elsif do_action == 'unbind'
                state_unit.unbind!
              end
            end
          end
          ret["result"] = "success"
        else
          ret["result"] = "error"
          ret["errors"] = []
          not_found_ids.each do |state_unit_id|
            ret["errors"] << { id: state_unit_id,
                               message: "state_unit not found"
                              }
          end
        end
        render json: ret
      rescue
        ret["result"] = "error"
        ret["errors"] = []
        ret["errors"] << { id: nil,
                           message: "error on_save"
                          }
        render json: ret
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