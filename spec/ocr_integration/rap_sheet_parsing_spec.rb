require 'rails_helper'

RSpec.describe 'ocr parsing accuracy' do
  # Skipped for now
  xit 'is accurate' do
    summary_stats = {
      actual_convictions: 0,
      detected_convictions: 0,
      correctly_detected_convictions: 0
    }

    rap_sheet_directories = Dir['test_rap_sheet_data/*'].select { |e| File.directory? e }
    rap_sheet_directories.each do |directory|


      rap_sheet = RapSheet.create!
      expected_values = JSON.parse(File.read("#{directory}/expected_values.json"))

      num_pages = Dir["#{directory}/*.jpg"].length
      num_pages.times do |page_number|
        image = File.new("#{directory}/page_#{page_number}.jpg")
        RapSheetPage.scan_and_create(image: image, rap_sheet_id: rap_sheet.id)
      end

      expected_dates = expected_values['convictions'].map do |c|
        Date.strptime(c['date'], '%m/%d/%Y')
      end

      matches = rap_sheet.conviction_dates.select do |d|
        expected_dates.include? d
      end.length

      actual_convictions = expected_values['convictions'].length
      detected_convictions = rap_sheet.conviction_dates.length

      summary_stats[:actual_convictions] += actual_convictions
      summary_stats[:detected_convictions] += detected_convictions
      summary_stats[:correctly_detected_convictions] += matches

      puts "------------- For #{directory} -------------"
      puts "Actual Convictions: #{actual_convictions}"
      puts "Detected Convictions: #{detected_convictions}"
      puts "Correctly Detected Convictions: #{matches}"
      puts "Accuracy: #{matches.to_f / actual_convictions.to_f * 100}%"
    end

    puts '------------- Summary -------------'
    puts "Actual Convictions: #{summary_stats[:actual_convictions]}"
    puts "Detected Convictions: #{summary_stats[:detected_convictions]}"
    puts "Correctly Detected Convictions: #{summary_stats[:correctly_detected_convictions]}"
    puts "Accuracy: #{summary_stats[:correctly_detected_convictions].to_f / summary_stats[:actual_convictions].to_f * 100}%"
  end
end
