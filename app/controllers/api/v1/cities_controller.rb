module Api
  module V1
    class CitiesController < ApiController
      def index
        @cities = City.all
      end
    end
  end
end