module Api
  module V2
    class CfosController < ApiController
      def index
        @cfos = Cfo.all
      end
    end
  end
end