# Splits document text into overlapping chunks along paragraph boundaries,
# so each chunk stays small enough for focused retrieval while the overlap
# keeps context that spans a paragraph break from being lost at the seam.
class TextChunkerService
  CHUNK_SIZE = 1_000
  OVERLAP = 150

  def initialize(text, chunk_size: CHUNK_SIZE, overlap: OVERLAP)
    @text = text.to_s.gsub(/\r\n?/, "\n").strip
    @chunk_size = chunk_size
    @overlap = overlap
  end

  def chunks
    return [] if @text.empty?

    paragraph_chunks.flat_map { |chunk| hard_split(chunk) }
  end

  private

  def paragraph_chunks
    paragraphs = @text.split(/\n{2,}/).map(&:strip).reject(&:empty?)
    result = []
    buffer = +""

    paragraphs.each do |paragraph|
      if buffer.present? && buffer.size + paragraph.size + 2 > @chunk_size
        result << buffer.strip
        buffer = +(buffer[-@overlap..] || buffer)
      end
      buffer << (buffer.empty? ? "" : "\n\n") << paragraph
    end

    result << buffer.strip if buffer.present?
    result
  end

  # A single paragraph can still exceed chunk_size (e.g. a long table or
  # unbroken block of text) — fall back to a hard character split for it.
  def hard_split(chunk)
    return [ chunk ] if chunk.size <= @chunk_size * 1.5

    chunk.chars.each_slice(@chunk_size).map(&:join)
  end
end
