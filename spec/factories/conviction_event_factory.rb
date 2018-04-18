FactoryBot.define do
  factory :conviction_event do
    date nil
    case_number nil
    courthouse nil
    sentence nil
    counts nil

    initialize_with {
      new(date: date, case_number: case_number, courthouse: courthouse, sentence: sentence)
    }
  end
end
