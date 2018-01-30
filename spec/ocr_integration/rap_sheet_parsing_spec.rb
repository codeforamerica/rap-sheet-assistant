require 'rails_helper'

RSpec.describe 'ocr parsing accuracy', ocr_integration: true do
  it 'is accurate' do
    summary_stats = {
      actual_convictions: 0,
      detected_convictions: 0,
      correctly_detected_convictions: 0
    }

    connection = Fog::Storage.new({
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_KEY'],
    })

    directory = connection.directories.new(key: 'rap-sheet-test-data')
    file_names = directory.files.map(&:key)
    rap_sheets = file_names.map{|f| f.split('/')[0]}.uniq
    rap_sheets.each do |rap_sheet_prefix|
      rap_sheet = RapSheet.create!

      values_file = directory.files.get("#{rap_sheet_prefix}/expected_values.json")
      expected_convictions = JSON.parse(values_file.body, symbolize_names: true)[:convictions]
      expected_convictions.each do |c|
        c[:date] = Date.strptime(c[:date], '%m/%d/%Y')
      end

      pages = file_names.select {|f| f.starts_with?("#{rap_sheet_prefix}/page_")}

      pages.each do |page|
        image = File.open('/tmp/tmp_rap_sheet.jpg', 'wb')
        image.write(directory.files.get(page).body)
        RapSheetPage.scan_and_create(image: image, rap_sheet_id: rap_sheet.id)
        image.close
      end

      matches = rap_sheet.convictions.select do |c|
        if expected_convictions.include?(c)
          true
        else
          puts c
        end
      end.length

      actual_convictions = expected_convictions.length
      detected_convictions = rap_sheet.convictions.length

      summary_stats[:actual_convictions] += actual_convictions
      summary_stats[:detected_convictions] += detected_convictions
      summary_stats[:correctly_detected_convictions] += matches

      puts "------------- For #{rap_sheet_prefix} -------------"
      puts "Actual Convictions: #{actual_convictions}"
      puts "Detected Convictions: #{detected_convictions}"
      puts "Correctly Detected Convictions: #{matches}"
      puts "Accuracy: #{matches.to_f / actual_convictions.to_f * 100}%"
    end

    puts '------------- Summary -------------'
    puts "Actual Convictions: #{summary_stats[:actual_convictions]}"
    puts "Detected Convictions: #{summary_stats[:detected_convictions]}"
    puts "Correctly Detected Convictions: #{summary_stats[:correctly_detected_convictions]}"
    accuracy = summary_stats[:correctly_detected_convictions].to_f / summary_stats[:actual_convictions].to_f
    puts "Accuracy: #{accuracy * 100}%"

    expect(accuracy).to be > 0.9
  end
end
