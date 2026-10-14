# Orchestrates one turn of the RAG pipeline: embed the question, retrieve the
# most relevant chunks across the chatbot's documents, call the LLM with that
# context plus recent history, then persist both sides of the exchange.
class RagChatService
  HISTORY_LIMIT = 10
  TOP_K = 4

  def initialize(chatbot, conversation)
    @chatbot = chatbot
    @conversation = conversation
  end

  def ask(question)
    history = @conversation.messages.order(:created_at).last(HISTORY_LIMIT)
    @conversation.messages.create!(role: :user, content: question)

    if @chatbot.chunks.none?
      return save_assistant_reply(
        "Bu asistan için henüz bir doküman yüklenmedi, bu yüzden sorularınızı yanıtlayamıyorum.",
        []
      )
    end

    query_embedding = EmbeddingService.new.embed_query(question)
    top_chunks = ChunkRetrievalService.new(@chatbot).search(query_embedding, top_k: TOP_K)

    answer = ChatResponderService.new(@chatbot).respond(
      question: question,
      context_chunks: top_chunks,
      history: history
    )

    save_assistant_reply(answer, cited_sources(answer, top_chunks))
  end

  private

  # Only surface sources the model actually cited (e.g. "[1]"), so an "I
  # don't know" answer doesn't misleadingly show a document as its source.
  def cited_sources(answer, top_chunks)
    cited_indices = answer.scan(/\[(\d+)\]/).flatten.map(&:to_i).uniq
    cited_indices.filter_map { |i| top_chunks[i - 1]&.document&.title }.uniq
  end

  def save_assistant_reply(answer, sources)
    @conversation.messages.create!(role: :assistant, content: answer, sources: sources)
    { answer: answer, sources: sources }
  end
end
