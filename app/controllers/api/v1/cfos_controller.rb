module Api
  module V1
    class CfosController < ApiController
      def index
        @cfos = Cfo.all
      end
    end
  end
end