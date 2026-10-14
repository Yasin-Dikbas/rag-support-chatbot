module Api
  module Widget
    class ChatbotsController < BaseController
      before_action :set_chatbot

      # GET /api/widget/:widget_key
      def show
        render json: {
          name: @chatbot.name,
          welcome_message: @chatbot.welcome_message
        }
      end
    end
  end
end
