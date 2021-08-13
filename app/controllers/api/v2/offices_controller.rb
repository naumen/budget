module Api
  module V2
    class OfficesController < ApiController
      def index
        @offices = Location.all
      end
    end
  end
end