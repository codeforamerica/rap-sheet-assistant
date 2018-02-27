require 'rails_helper'

RSpec.describe CaseInformationForm do
  let(:user) { FactoryBot.create(:user) }
  let(:valid_attributes) do
    ActionController::Parameters.new(
      on_parole: 'true',
      on_probation: 'true',
      finished_half_of_probation: 'true',
      outstanding_warrant: 'true',
      owe_fees: 'true'
    ).permit!
  end

  it 'persists values onto the user object' do
    form = CaseInformationForm.new(valid_attributes)
    form.save(user)
    expected_attributes = {
      on_parole: true,
      on_probation: true,
      finished_half_of_probation: true,
      outstanding_warrant: true,
      owe_fees: true     
    }.stringify_keys
    expect(user.attributes).to match(a_hash_including(expected_attributes))
  end

  context 'when "on_probation" is false' do
    before do
      user.update(finished_half_of_probation: true)
    end

    it 'always nullifies finished_half_of_probation' do
      form = CaseInformationForm.new(valid_attributes.merge(on_probation: 'false'))
      form.save(user)
      user.reload

      expect(user.on_probation).to be_falsey
      expect(user.finished_half_of_probation).to eq(nil)
    end
  end
end
