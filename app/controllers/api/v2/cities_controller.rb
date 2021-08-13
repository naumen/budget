module Api
  module V2
    class CitiesController < ApiController
      def index
        @cities = City.all
      end
    end
  end
end