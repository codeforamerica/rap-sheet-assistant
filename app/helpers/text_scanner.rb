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
    self.retrieve_key_file

    require 'google/cloud/vision'
    image_annotator = Google::Cloud::Vision::ImageAnnotator.new
    response_batch = image_annotator.document_text_detection image: image_path, image_context: { "language_hints" => [:en] }
    scanned_text = ""
    response_batch.responses.each do |res|
      scanned_text << res.full_text_annotation.text
    end
    scanned_text
  end

  def self.retrieve_key_file
    return if File.file?(ENV['GOOGLE_CLOUD_KEYFILE'])

    connection = Fog::Storage.new({
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_KEY'],
    })

    directory = connection.directories.new(key: ENV['ASSETS_BUCKET'])

    body = directory.files.get(ENV['GOOGLE_CLOUD_KEYFILE']).body

    File.open(ENV['GOOGLE_CLOUD_KEYFILE'], 'w') {|f| f.write(body)}
  end
end
