require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#full_name' do
    it 'returns nil if first or last name is missing' do
      expect(FactoryBot.build(:user).full_name).to be_nil
    end

    it 'combines first and last name' do
      expect(FactoryBot.build(:user, first_name: 'Jane', last_name: 'Smith').full_name).to eq('Jane Smith')
    end
  end
end
