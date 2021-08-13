module Api
  module V2
    class DivisionsController < ApiController
      def index
        @divisions = Division.all
      end
    end
  end
end