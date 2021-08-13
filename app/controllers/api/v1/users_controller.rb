module Api
  module V1
    class UsersController < ApiController
      def index
        @users = User.all
      end

      def user_salaries
        config = YAML.load_file("#{Rails.root}/config/settings.yml")
        @items = []
        if !params["accesskey"].blank? && params["accesskey"] == config["accesskey"]["user_salaries"]
          @items = User.user_salaries
        end
        render json: @items.to_json
      end
    end
  end
end