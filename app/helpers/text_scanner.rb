class TextScanner
  def self.scan_text(image_path)
    # self.scan_with_tesseract(image_path)
    self.scan_with_gcv(image_path)
  end

  private

  def self.scan_with_tesseract(image_path)
    whitelist = [*('A'..'Z'), *('0'..'9')].join + '*:-/.,()#&'

    RTesseract.new(image_path,
      processor: 'mini_magick',
      tessedit_char_whitelist: whitelist,
      user_words: Rails.root + './tesseract/words',
      user_patterns: Rails.root + './tesseract/patterns',
    ).to_s
  end

  def self.scan_with_gcv(image_path)
    require 'google/cloud/vision'
    vision = Google::Cloud::Vision.new(project: ENV['GOOGLE_PROJECT_ID'])
    vision.image(image_path).document.text
  end
end
