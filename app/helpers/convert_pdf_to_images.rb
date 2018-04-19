class ConvertPdfToImages
  def self.convert(pdf_path, tmp_directory)
    MiniMagick::Tool::Convert.new do |convert|
      convert.density(300)
      convert.trim
      convert << pdf_path
      convert.quality(100)
      convert << "#{tmp_directory}/page.jpg"
    end

    Dir["#{tmp_directory}/page-*.jpg"]
  end
end
