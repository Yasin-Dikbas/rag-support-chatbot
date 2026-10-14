module Api
  class ChatbotsController < ApplicationController
    before_action :set_chatbot, only: [ :show, :update, :destroy, :regenerate_widget_key ]

    # GET /api/chatbots
    def index
      chatbots = current_user.chatbots.order(created_at: :desc)
      render json: chatbots.map { |c| chatbot_json(c) }
    end

    # POST /api/chatbots
    def create
      chatbot = current_user.chatbots.new(chatbot_params)

      if chatbot.save
        render json: chatbot_json(chatbot), status: :created
      else
        render json: { errors: chatbot.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # GET /api/chatbots/:id
    def show
      render json: chatbot_json(@chatbot, detailed: true)
    end

    # PATCH /api/chatbots/:id
    def update
      if @chatbot.update(chatbot_params)
        render json: chatbot_json(@chatbot, detailed: true)
      else
        render json: { errors: @chatbot.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/chatbots/:id
    def destroy
      @chatbot.destroy
      head :no_content
    end

    # POST /api/chatbots/:id/regenerate_widget_key
    def regenerate_widget_key
      @chatbot.regenerate_widget_key!
      render json: chatbot_json(@chatbot, detailed: true)
    end

    private

    def set_chatbot
      @chatbot = current_user.chatbots.find(params[:id])
    end

    def chatbot_params
      params.permit(:name, :description, :welcome_message)
    end

    def chatbot_json(chatbot, detailed: false)
      base = {
        id: chatbot.id,
        name: chatbot.name,
        description: chatbot.description,
        welcome_message: chatbot.welcome_message,
        widget_key: chatbot.widget_key,
        created_at: chatbot.created_at
      }

      return base unless detailed

      base.merge(
        documents_count: chatbot.documents.count,
        completed_documents_count: chatbot.documents.completed.count,
        chunks_count: chatbot.chunks.count,
        conversations_count: chatbot.conversations.count
      )
    end
  end
end
