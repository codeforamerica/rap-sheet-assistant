require 'rails_helper'

RSpec.describe 'ocr parsing accuracy', ocr_integration: true do
  let(:directory) do
    connection = Fog::Storage.new({
                                      provider: 'AWS',
                                      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                      aws_secret_access_key: ENV['AWS_SECRET_KEY'],
                                  })

    connection.directories.new(key: 'rap-sheet-test-data')
  end

  it 'is accurate' do
    summary_stats = {
      actual_convictions: 0,
      detected_convictions: 0,
      correctly_detected_convictions: 0
    }

    file_names = directory.files.map(&:key)
    rap_sheets = file_names.map{|f| f.split('/')[0]}.uniq
    rap_sheets.each do |rap_sheet_prefix|
      puts "------------- For #{rap_sheet_prefix} -------------"
      rap_sheet = create_rap_sheet(file_names, rap_sheet_prefix)

      expected_convictions = expected_values(rap_sheet_prefix)
      matches = rap_sheet.convictions.select do |c|
        if expected_convictions.include?(c)
          true
        else
          puts "Parsed conviction #{c} failed to match expectations"
        end
      end.length

      actual_convictions = expected_convictions.length
      detected_convictions = rap_sheet.convictions.length

      summary_stats[:actual_convictions] += actual_convictions
      summary_stats[:detected_convictions] += detected_convictions
      summary_stats[:correctly_detected_convictions] += matches

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

def expected_values(rap_sheet_prefix)
  values_file = directory.files.get("#{rap_sheet_prefix}/expected_values.json")
  expected_convictions = JSON.parse(values_file.body, symbolize_names: true)[:convictions]
  expected_convictions.each do |c|
    c[:date] = Date.strptime(c[:date], '%m/%d/%Y')
    c[:case_number] = c[:case_number].gsub(' ', '')
  end
  expected_convictions
end

def fetch_or_scan_text(file_names, page)
  text_path = page.gsub('.jpg', '.txt')
  if file_names.include? text_path
    text = directory.files.get(text_path).body
  else
    image = File.open('/tmp/tmp_rap_sheet.jpg', 'wb')
    image.write(directory.files.get(page).body)

    text = TextScanner.scan_text(image.path)
    image.close

    directory.files.create(key: text_path, body: text, public: false)
  end
  text
end

def create_rap_sheet(file_names, rap_sheet_prefix)
  rap_sheet = RapSheet.create!


  pages = file_names.select {|f| f.starts_with?("#{rap_sheet_prefix}/page_") && f.ends_with?('.jpg')}

  pages.each do |page|
    text = fetch_or_scan_text(file_names, page)

    RapSheetPage.create!(rap_sheet_id: rap_sheet.id, text: text)
  end
  rap_sheet
end
