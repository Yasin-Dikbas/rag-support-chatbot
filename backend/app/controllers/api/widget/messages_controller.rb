module Api
  module Widget
    class MessagesController < BaseController
      MAX_MESSAGE_CHARS = 2_000

      before_action :set_chatbot

      # POST /api/widget/:widget_key/messages
      def create
        message = params.require(:message).to_s.strip
        visitor_id = params.require(:visitor_id).to_s.strip

        if message.blank? || message.length > MAX_MESSAGE_CHARS
          render json: { error: "Mesaj boş olamaz veya çok uzun (max #{MAX_MESSAGE_CHARS} karakter)" }, status: :unprocessable_entity
          return
        end

        conversation = find_or_create_conversation(visitor_id)
        result = RagChatService.new(@chatbot, conversation).ask(message)

        render json: { conversation_id: conversation.id, answer: result[:answer], sources: result[:sources] }
      rescue => e
        Rails.logger.error("Widget chat error: #{e.class} #{e.message}")
        render json: { error: "Şu anda yanıt üretilemedi, lütfen tekrar deneyin." }, status: :bad_gateway
      end

      private

      def find_or_create_conversation(visitor_id)
        if params[:conversation_id].present?
          @chatbot.conversations.find_by(id: params[:conversation_id], visitor_id: visitor_id) ||
            @chatbot.conversations.create!(visitor_id: visitor_id)
        else
          @chatbot.conversations.create!(visitor_id: visitor_id)
        end
      end
    end
  end
end
