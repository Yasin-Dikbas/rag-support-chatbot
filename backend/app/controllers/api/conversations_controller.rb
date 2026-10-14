module Api
  class ConversationsController < ApplicationController
    before_action :set_chatbot
    before_action :set_conversation, only: [ :show ]

    # GET /api/chatbots/:chatbot_id/conversations
    def index
      conversations = @chatbot.conversations.includes(:messages).order(updated_at: :desc)

      render json: conversations.map { |c| conversation_summary_json(c) }
    end

    # GET /api/chatbots/:chatbot_id/conversations/:id
    def show
      render json: {
        id: @conversation.id,
        visitor_id: @conversation.visitor_id,
        messages: @conversation.messages.order(:created_at).map { |m| message_json(m) }
      }
    end

    private

    def set_chatbot
      @chatbot = current_user.chatbots.find(params[:chatbot_id])
    end

    def set_conversation
      @conversation = @chatbot.conversations.find(params[:id])
    end

    def conversation_summary_json(conversation)
      last_message = conversation.messages.max_by(&:created_at)

      {
        id: conversation.id,
        visitor_id: conversation.visitor_id,
        message_count: conversation.messages.size,
        last_message: last_message&.content,
        updated_at: conversation.updated_at
      }
    end

    def message_json(message)
      {
        id: message.id,
        role: message.role,
        content: message.content,
        sources: message.sources,
        created_at: message.created_at
      }
    end
  end
end
