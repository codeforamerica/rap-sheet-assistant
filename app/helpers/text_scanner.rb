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
    vision = Google::Cloud::Vision.new(project: ENV['GOOGLE_PROJECT_ID'])
    image = vision.image(image_path)
    image.context.languages = [:en]
    image.document.text
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
