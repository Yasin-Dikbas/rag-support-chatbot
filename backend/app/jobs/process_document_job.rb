class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    document.update!(status: :processing, error_message: nil)

    text = DocumentTextExtractorService.new(document).extract
    chunk_texts = TextChunkerService.new(text).chunks
    raise "Dökümandan hiç metin parçası çıkarılamadı" if chunk_texts.empty?

    embeddings = EmbeddingService.new.embed_documents(chunk_texts)

    Chunk.transaction do
      document.chunks.destroy_all
      chunk_texts.each_with_index do |content, i|
        document.chunks.create!(chatbot_id: document.chatbot_id, content: content, embedding: embeddings[i], chunk_index: i)
      end
    end

    document.update!(status: :completed, raw_text: text, char_count: text.length, chunk_count: chunk_texts.size)
  rescue => e
    document&.update(status: :failed, error_message: e.message)
    raise
  end
end
