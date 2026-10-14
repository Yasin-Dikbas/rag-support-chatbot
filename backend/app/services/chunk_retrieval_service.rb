# Finds the most relevant chunks for a question via in-memory cosine similarity.
#
# This deliberately skips the pgvector extension: it isn't available on this
# machine without compiling it or installing an unofficial third-party binary
# into the PostgreSQL install, and the scale of a portfolio-sized knowledge
# base (low thousands of chunks per chatbot) makes a plain Ruby scan fast
# enough. If the extension becomes available, swap the `embedding` column for
# `vector` and this class for an `ORDER BY embedding <=> ?` query.
class ChunkRetrievalService
  def initialize(chatbot)
    @chatbot = chatbot
  end

  def search(query_embedding, top_k: 4)
    @chatbot.chunks.includes(:document)
      .map { |chunk| [ chunk, chunk.cosine_similarity(query_embedding) ] }
      .sort_by { |(_, score)| -score }
      .first(top_k)
      .map(&:first)
  end
end
