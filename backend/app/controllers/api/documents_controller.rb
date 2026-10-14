module Api
  class DocumentsController < ApplicationController
    MAX_FILE_BYTES = 15.megabytes

    before_action :set_chatbot
    before_action :set_document, only: [ :destroy, :retry ]

    # GET /api/chatbots/:chatbot_id/documents
    def index
      render json: @chatbot.documents.order(created_at: :desc).map { |d| document_json(d) }
    end

    # POST /api/chatbots/:chatbot_id/documents
    def create
      document = build_document

      if document.nil?
        render json: { errors: [ "Dosya veya metin gerekli" ] }, status: :unprocessable_entity
        return
      end

      if document.save
        ProcessDocumentJob.perform_later(document.id)
        render json: document_json(document), status: :created
      else
        render json: { errors: document.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/chatbots/:chatbot_id/documents/:id
    def destroy
      @document.destroy
      head :no_content
    end

    # POST /api/chatbots/:chatbot_id/documents/:id/retry
    def retry
      @document.update!(status: :pending, error_message: nil)
      ProcessDocumentJob.perform_later(@document.id)
      render json: document_json(@document)
    end

    private

    def set_chatbot
      @chatbot = current_user.chatbots.find(params[:chatbot_id])
    end

    def set_document
      @document = @chatbot.documents.find(params[:id])
    end

    def build_document
      if params[:file].present?
        build_file_document
      elsif params[:source_text].present?
        build_text_document
      end
    end

    def build_file_document
      upload = params[:file]

      unless Document::SUPPORTED_CONTENT_TYPES.include?(upload.content_type)
        return @chatbot.documents.new.tap { |d| d.errors.add(:file, "sadece PDF, Markdown veya metin dosyası yüklenebilir") }
      end

      if upload.size > MAX_FILE_BYTES
        return @chatbot.documents.new.tap { |d| d.errors.add(:file, "15 MB'tan büyük olamaz") }
      end

      @chatbot.documents.new(
        title: params[:title].presence || upload.original_filename,
        source_type: :file
      ).tap { |d| d.file.attach(upload) }
    end

    def build_text_document
      @chatbot.documents.new(
        title: params[:title].presence || "Yapıştırılan metin",
        source_type: :text,
        source_text: params[:source_text]
      )
    end

    def document_json(document)
      {
        id: document.id,
        title: document.title,
        source_type: document.source_type,
        status: document.status,
        error_message: document.error_message,
        char_count: document.char_count,
        chunk_count: document.chunk_count,
        created_at: document.created_at
      }
    end
  end
end
