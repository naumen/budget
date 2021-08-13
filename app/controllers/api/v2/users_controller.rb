module Api
  module V2
    class UsersController < ApiController
      def index
        @users = User.all
      end
    end
  end
end