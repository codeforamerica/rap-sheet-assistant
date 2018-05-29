require 'rails_helper'

RSpec.describe 'ocr parsing accuracy', ocr_integration: true do
  let(:directory) do
    connection = Fog::Storage.new(fog_params)
    connection.directories.new(key: 'rap-sheet-test-data')
  end

  it 'is accurate' do
    @summary_stats = {
      convictions: {
        actual: 0,
        detected: 0,
        correctly_detected: 0
      },
      arrests: {
        actual: 0,
        detected: 0,
        correctly_detected: 0
      },
      custody_events: {
        actual: 0,
        detected: 0,
        correctly_detected: 0
      }
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

      puts 'Convictions:'
      summarize(
        detected_convictions(rap_sheet),
        expected_convictions(expected_values),
        :convictions
      )

      puts 'Arrests:'
      summarize(
        detected_arrests(rap_sheet),
        expected_arrests(expected_values),
        :arrests
      )

      puts 'Custody Events:'
      summarize(
        detected_custody_events(rap_sheet),
        expected_custody_events(expected_values),
        :custody_events
      )
    end

    puts '------------- Summary -------------'
    conviction_accuracy = compute_accuracy(
      @summary_stats[:convictions][:correctly_detected],
      @summary_stats[:convictions][:actual],
      :convictions
    )

    arrest_accuracy = compute_accuracy(
      @summary_stats[:arrests][:correctly_detected],
      @summary_stats[:arrests][:actual],
      :arrests
    )

    custody_accuracy = compute_accuracy(
      @summary_stats[:custody_events][:correctly_detected],
      @summary_stats[:custody_events][:actual],
      :custody_events
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
  sorted(expected_values[:convictions].map do |c|
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
  end)
end

def expected_arrests(expected_values)
  sorted(expected_values[:arrests].map do |c|
    date = c[:date] ? Date.strptime(c[:date], '%m/%d/%Y') : nil

    {
      date: date,
    }
  end)
end

def expected_custody_events(expected_values)
  sorted(expected_values[:custody_events].map do |c|
    date = c[:date] ? Date.strptime(c[:date], '%m/%d/%Y') : nil

    {
      date: date,
    }
  end)
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
  rap_sheet = create(:rap_sheet, number_of_pages: pages.count)

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

def compute_accuracy(matches, actual_convictions, key)
  puts "Correctly detected #{matches} out of #{actual_convictions} #{key}"

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
    case_number = c[:case_number] ? c[:case_number] : ''
    
    [date, case_number]
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

def num_matches(detected, expected)
  puts diff(detected, expected)

  detected.select { |c| expected.include?(c) }.length
end

def summarize(detected, expected, key)
  matches = num_matches(detected, expected)

  puts "Detected #{key}: #{detected.length}"
  puts "Accuracy: #{compute_accuracy(matches, expected.length, key)}%"

  @summary_stats[key][:actual] += expected.length
  @summary_stats[key][:detected] += detected.length
  @summary_stats[key][:correctly_detected] += matches
end
