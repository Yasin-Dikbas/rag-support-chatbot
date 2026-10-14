require "faraday"

class ChatResponderService
  API_BASE = "https://generativelanguage.googleapis.com/v1beta/"

  def initialize(chatbot, model: ENV.fetch("GEMINI_CHAT_MODEL", "gemini-2.5-flash"))
    @chatbot = chatbot
    @api_key = ENV.fetch("GEMINI_API_KEY")
    @model = model
  end

  def respond(question:, context_chunks:, history:)
    response = connection.post("models/#{@model}:generateContent") do |req|
      req.params["key"] = @api_key
      req.body = {
        system_instruction: { parts: [ { text: system_prompt(context_chunks) } ] },
        contents: build_contents(history, question),
        generationConfig: { temperature: 0.3 }
      }
    end

    raise "Gemini API error (#{response.status}): #{response.body}" unless response.success?

    response.body.dig("candidates", 0, "content", "parts", 0, "text").to_s.strip
  end

  private

  def build_contents(history, question)
    history.map { |m| { role: m.user? ? "user" : "model", parts: [ { text: m.content } ] } } +
      [ { role: "user", parts: [ { text: question } ] } ]
  end

  def system_prompt(context_chunks)
    context = context_chunks.each_with_index.map do |chunk, i|
      "[#{i + 1}] (kaynak: #{chunk.document.title})\n#{chunk.content}"
    end.join("\n\n")

    <<~PROMPT
      Sen "#{@chatbot.name}" adlı bir kurumsal destek asistanısın.
      #{@chatbot.description.presence}

      Sadece aşağıda verilen bağlam (context) belgelerindeki bilgilere dayanarak cevap ver.
      Cevap bağlamda yoksa, bunu bilmediğini söyle ve kullanıcıyı insan destek ekibine yönlendir
      — asla bağlamda olmayan bir bilgi uydurma.
      Kullanıcının sorduğu dilde cevap ver.
      İlgili olduğunda cevabında [1], [2] gibi kaynak numaralarıyla atıf yap.

      Bağlam:
      #{context}
    PROMPT
  end

  def connection
    Faraday.new(url: API_BASE) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end
end
