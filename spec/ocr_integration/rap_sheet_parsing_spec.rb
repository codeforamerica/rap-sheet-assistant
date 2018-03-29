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
      actual_arrests: 0,
      detected_arrests: 0,
      correctly_detected_arrests: 0,
      actual_custody_events: 0,
      detected_custody_events: 0,
      correctly_detected_custody_events: 0,
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
      values_file = directory.files.get("#{rap_sheet_prefix}/expected_values.json")
      expected_values = JSON.parse(values_file.body, symbolize_names: true)

      detected_convictions = detected_convictions(rap_sheet)
      expected_convictions = sorted(expected_convictions(expected_values))
      puts 'Convictions Diff:'
      puts diff(detected_convictions, expected_convictions)

      convictions_matches = detected_convictions.select do |c|
        expected_convictions.include?(c)
      end.length

      actual_convictions_count = expected_convictions.length
      detected_convictions_count = detected_convictions.length

      summary_stats[:actual_convictions] += actual_convictions_count
      summary_stats[:detected_convictions] += detected_convictions_count
      summary_stats[:correctly_detected_convictions] += convictions_matches

      puts "Detected Convictions: #{detected_convictions_count}"
      puts "Correctly detected #{convictions_matches} out of #{actual_convictions_count} convictions"
      puts "Accuracy: #{compute_accuracy(convictions_matches, actual_convictions_count)}%"

      detected_arrests = detected_arrests(rap_sheet)
      expected_arrests = sorted(expected_arrests(expected_values))
      puts 'Arrests Diff:'
      puts diff(detected_arrests, expected_arrests)

      arrests_matches = detected_arrests.select do |c|
        expected_arrests.include?(c)
      end.length

      actual_arrests_count = expected_arrests.length
      detected_arrests_count = detected_arrests.length

      summary_stats[:actual_arrests] += actual_arrests_count
      summary_stats[:detected_arrests] += detected_arrests_count
      summary_stats[:correctly_detected_arrests] += arrests_matches

      detected_custody_events = detected_custody_events(rap_sheet)
      expected_custody_events = sorted(expected_custody_events(expected_values))
      puts 'Arrests Diff:'
      puts diff(detected_custody_events, expected_custody_events)

      custody_events_matches = detected_custody_events.select do |c|
        expected_custody_events.include?(c)
      end.length

      actual_custody_events_count = expected_custody_events.length
      detected_custody_events_count = detected_custody_events.length

      summary_stats[:actual_custody_events] += actual_custody_events_count
      summary_stats[:detected_custody_events] += detected_custody_events_count
      summary_stats[:correctly_detected_custody_events] += custody_events_matches

      puts "Detected Arrests: #{detected_custody_events_count}"
      puts "Correctly detected #{custody_events_matches} out of #{actual_custody_events_count} custody_events"
      puts "Accuracy: #{compute_accuracy(custody_events_matches, actual_custody_events_count)}%"
    end

    puts '------------- Summary -------------'
    puts "Correctly detected #{summary_stats[:correctly_detected_convictions]} out of #{summary_stats[:actual_convictions]} convictions"
    conviction_accuracy = compute_accuracy(
      summary_stats[:correctly_detected_convictions],
      summary_stats[:actual_convictions]
    )

    puts "Correctly detected #{summary_stats[:correctly_detected_arrests]} out of #{summary_stats[:actual_arrests]} arrests"
    arrest_accuracy = compute_accuracy(
      summary_stats[:correctly_detected_arrests],
      summary_stats[:actual_arrests]
    )

    puts "Correctly detected #{summary_stats[:correctly_detected_custody_events]} out of #{summary_stats[:actual_custody_events]} custody_events"
    custody_accuracy = compute_accuracy(
      summary_stats[:correctly_detected_custody_events],
      summary_stats[:actual_custody_events]
    )

    puts "Conviction Accuracy: #{conviction_accuracy}%"
    puts "Arrest Accuracy: #{arrest_accuracy}%"
    puts "Custody Event Accuracy: #{custody_accuracy}%"

    expect(conviction_accuracy).to be > 75
    expect(arrest_accuracy).to be > 75
    expect(custody_accuracy).to be > 75
  end
end

def expected_convictions(expected_values)
  expected_values[:convictions].map do |c|
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

def expected_arrests(expected_values)
  expected_values[:arrests].map do |c|
    date = c[:date] ? Date.strptime(c[:date], '%m/%d/%Y') : nil

    {
      date: date,
    }
  end
end

def expected_custody_events(expected_values)
  expected_values[:custody_events].map do |c|
    date = c[:date] ? Date.strptime(c[:date], '%m/%d/%Y') : nil

    {
      date: date,
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
  return 100 if actual_convictions == 0

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

def sorted(items)
  items.sort_by do |c|
    date = c[:date] ? c[:date] : Date.new(1000, 1, 1) # arbitrarily old date
    [date, c[:case_number]]
  end
end

def diff(*args)
  RSpec::Support::Differ.new(color: true).diff(*args)
end

def detected_convictions(rap_sheet)
  sorted(rap_sheet.events.with_convictions.map do |event|
    {
      date: event.date,
      case_number: event.case_number,
      courthouse: event.courthouse.upcase,
      sentence: event.sentence.to_s,
      counts: event.counts.map do |count|
        {
          'code_section' => count.code_section&.upcase,
          'severity' => count.severity&.first,
        }
      end
    }
  end)
end

def detected_arrests(rap_sheet)
  sorted(rap_sheet.events.arrests.map do |event|
    {
      date: event.date
    }
  end)
end

def detected_custody_events(rap_sheet)
  sorted(rap_sheet.events.custody_events.map do |event|
    {
      date: event.date
    }
  end)
end
