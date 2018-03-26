require 'spec_helper'

RSpec.describe ConvictionEvent do
  describe '#severity' do
    it 'returns the highest severity found within the counts' do
      event = described_class.new(date: nil, case_number: nil, courthouse: nil, sentence:nil)

      event.counts = [double(severity: 'F')]
      expect(event.severity).to eq 'F'

      event.counts = [double(severity: 'I'), double(severity: 'F')]
      expect(event.severity).to eq 'F'

      event.counts = [double(severity: 'I'), double(severity: 'M')]
      expect(event.severity).to eq 'M'

      event.counts = [double(severity: 'I'), double(severity: 'I')]
      expect(event.severity).to eq 'I'
    end
  end
end
