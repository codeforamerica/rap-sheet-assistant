FactoryBot.define do
  factory :attorney do
    name { 'Anita Earls' }
    firm_name { 'NC Center for Civil Rights' }
    street_address { '2 E Morgan St' }
    city { 'Raleigh' }
    state { 'NC' }
    zip { '27601' }
    state_bar_number { '12345678' }
  end
end
