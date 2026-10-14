require "pdf-reader"

class DocumentTextExtractorService
  class ExtractionError < StandardError; end

  def initialize(document)
    @document = document
  end

  def extract
    return @document.source_text if @document.text?

    raise ExtractionError, "Dosya eklenmemiş" unless @document.file.attached?

    case @document.file.content_type
    when "application/pdf"
      extract_pdf
    else
      @document.file.download.force_encoding("UTF-8").scrub
    end
  end

  private

  def extract_pdf
    @document.file.open do |tempfile|
      reader = PDF::Reader.new(tempfile.path)
      text = reader.pages.map(&:text).join("\n\n")
      raise ExtractionError, "PDF'ten metin çıkarılamadı (muhtemelen taranmış görüntü)" if text.strip.empty?
      text
    end
  rescue PDF::Reader::MalformedPDFError => e
    raise ExtractionError, "Geçersiz veya bozuk PDF: #{e.message}"
  end
end
