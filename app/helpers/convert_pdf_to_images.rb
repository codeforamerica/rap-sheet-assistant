class ConvertPdfToImages
  def self.convert(pdf_path, tmp_directory)
    MiniMagick::Tool::Convert.new do |convert|
      convert.density(300)
      convert.trim
      convert << pdf_path
      convert.quality(100)
      convert << "#{tmp_directory}/page.jpg"
    end

    num_pages = Dir["#{tmp_directory}/page*.jpg"].length
    if num_pages == 1
      ["#{tmp_directory}/page.jpg"]
    else
      num_pages.times.map do |i|
        "#{tmp_directory}/page-#{i}.jpg"
      end
    end
  end
end
