module Api
  module V1
    class DivisionsController < ApiController
      def index
        @divisions = Division.all
      end
    end
  end
end