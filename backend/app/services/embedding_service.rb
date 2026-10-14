require "faraday"

# Wraps the Gemini embedding API. Chunks are embedded with taskType
# RETRIEVAL_DOCUMENT and user questions with RETRIEVAL_QUERY, which Gemini
# uses to optimize the two kinds of vectors for asymmetric similarity search.
class EmbeddingService
  API_BASE = "https://generativelanguage.googleapis.com/v1beta/"
  MODEL = ENV.fetch("GEMINI_EMBEDDING_MODEL", "gemini-embedding-001")
  DIMENSIONS = 768

  # Gemini's batchEmbedContents caps a single request at 100 items.
  BATCH_SIZE = 90

  def initialize
    @api_key = ENV.fetch("GEMINI_API_KEY")
  end

  def embed_documents(texts)
    texts.each_slice(BATCH_SIZE).flat_map { |batch| batch_embed(batch, "RETRIEVAL_DOCUMENT") }
  end

  def embed_query(text)
    batch_embed([ text ], "RETRIEVAL_QUERY").first
  end

  private

  def batch_embed(texts, task_type)
    response = connection.post("models/#{MODEL}:batchEmbedContents") do |req|
      req.params["key"] = @api_key
      req.body = {
        requests: texts.map do |text|
          {
            model: "models/#{MODEL}",
            content: { parts: [ { text: text } ] },
            taskType: task_type,
            outputDimensionality: DIMENSIONS
          }
        end
      }
    end

    raise "Gemini embedding error (#{response.status}): #{response.body}" unless response.success?

    response.body["embeddings"].map { |e| e["values"] }
  end

  def connection
    Faraday.new(url: API_BASE) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end
end
