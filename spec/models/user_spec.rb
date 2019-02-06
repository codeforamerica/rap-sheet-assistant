require 'rails_helper'

describe User do

  describe '#format_name' do

    it 'formats the name' do
      user = User.new(name: 'LAST,FIRST MIDDLE')
      user.format_name
      expect(user.name).to eq('FIRST MIDDLE LAST')
    end
  end
end
