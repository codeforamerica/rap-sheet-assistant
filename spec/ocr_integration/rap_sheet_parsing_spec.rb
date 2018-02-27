require 'rails_helper'

RSpec.describe 'ocr parsing accuracy', ocr_integration: true do
  let(:directory) do
    connection = Fog::Storage.new(fog_params)
    connection.directories.new(key: 'rap-sheet-test-data')
  end

  it 'is accurate' do
    summary_stats = {
      actual_convictions: 0,
      detected_convictions: 0,
      correctly_detected_convictions: 0,
    }

    file_names = directory.files.map(&:key)

    if ENV['TEST_DIR']
      rap_sheets = ENV['TEST_DIR'].split(' ')
    else
      rap_sheets = file_names.map { |f| f.split('/')[0] }.uniq
    end

    rap_sheets.each do |rap_sheet_prefix|
      puts "------------- For #{rap_sheet_prefix} -------------"
      rap_sheet = create_rap_sheet(file_names, rap_sheet_prefix)

      expected_convictions = expected_values(rap_sheet_prefix)
      detected_convictions = rap_sheet.events_with_convictions.map do |event|
        {
          date: event.date,
          case_number: event.case_number,
          courthouse: event.courthouse.upcase,
          sentence: event.sentence,
          counts: event.counts.map do |count|
            {
              'code_section' => count.code_section,
              'severity' => count.severity&.first,
            }
          end
        }
      end

      puts RSpec::Support::Differ.new(color: true).diff(
        sorted(detected_convictions),
        sorted(expected_convictions)
      )

      matches = detected_convictions.select do |c|
        expected_convictions.include?(c)
      end.length

      actual_convictions = expected_convictions.length
      detected_convictions = detected_convictions.length

      summary_stats[:actual_convictions] += actual_convictions
      summary_stats[:detected_convictions] += detected_convictions
      summary_stats[:correctly_detected_convictions] += matches

      puts "Detected Convictions: #{detected_convictions}"
      puts "Correctly detected #{matches} out of #{actual_convictions} convictions"
      puts "Accuracy: #{compute_accuracy(matches, actual_convictions)}%"
    end

    puts '------------- Summary -------------'
    puts "Detected Convictions: #{summary_stats[:detected_convictions]}"
    puts "Correctly detected #{summary_stats[:correctly_detected_convictions]} out of #{summary_stats[:actual_convictions]} convictions"
    accuracy = compute_accuracy(summary_stats[:correctly_detected_convictions], summary_stats[:actual_convictions])
    puts "Accuracy: #{accuracy}%"

    expect(accuracy).to be > 75
  end
end

def expected_values(rap_sheet_prefix)
  values_file = directory.files.get("#{rap_sheet_prefix}/expected_values.json")
  expected_convictions = JSON.parse(values_file.body, symbolize_names: true)[:convictions]
  expected_convictions.map do |c|
    {
      date: Date.strptime(c[:date], '%m/%d/%Y'),
      case_number: c[:case_number]&.gsub(' ', ''),
      courthouse: c[:courthouse].upcase.chomp(' CO'),
      sentence: c[:sentence],
      counts: c[:counts].map do |count|
        {
          'code_section' => count[:code_section],
          'severity' => count[:severity]
        }
      end
    }
  end
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
  pages = file_names.select { |f| f.starts_with?("#{rap_sheet_prefix}/page_") && f.ends_with?('.jpg') }
  rap_sheet = FactoryBot.create(:rap_sheet, number_of_pages: pages.count)

  pages.each do |page|
    text = fetch_or_scan_text(file_names, page)
    page_number = page.split('/page_')[1].chomp('.jpg').to_i

    RapSheetPage.create!(
      rap_sheet_id: rap_sheet.id,
      text: text,
      page_number: page_number,
    )
  end
  rap_sheet
end

def compute_accuracy(matches, actual_convictions)
  (matches.to_f / actual_convictions.to_f * 100).round(2)
end

def fog_params
  if ENV['LOCAL_ROOT']
    {
      provider: 'Local',
      local_root: ENV['LOCAL_ROOT'],
    }
  else
    {
      provider: 'aws',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_KEY']
    }
  end
end

def sorted(convictions)
  convictions.sort_by { |c| [c[:date], c[:case_number]] }
end
