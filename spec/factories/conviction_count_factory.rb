FactoryBot.define do
  factory :conviction_count do
    event nil
    code_section_description nil
    severity nil
    code nil
    section nil

    initialize_with { new(attributes) }
  end
end
