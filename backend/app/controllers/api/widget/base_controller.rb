module Api
  module Widget
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Chatbot not found" }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: e.message }, status: :bad_request
      end

      private

      def set_chatbot
        @chatbot = Chatbot.find_by!(widget_key: params[:widget_key])
      end
    end
  end
end
