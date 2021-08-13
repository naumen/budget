module Api
  module V2
    class PositionsController < ApiController
      def index
        @positions = Position.all
      end
    end
  end
end