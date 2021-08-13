module Api
  module V1
    class OfficesController < ApiController
      def index
        @offices = Location.all
      end
    end
  end
end