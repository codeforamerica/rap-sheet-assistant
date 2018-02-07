require 'spec_helper'
require_relative '../../app/helpers/text_cleaner'

describe TextCleaner do
  describe '.clean' do
    it 'replaces commonly mis-scanned text' do
      expect(clean('foo cNT: foo')).to eq('foo CNT: foo')
      expect(clean('wrong–dash')).to eq('wrong-dash')
      expect(clean('CNI: hi')).to eq('CNT: hi')
    end
  end
end

def clean(text)
  TextCleaner.clean(text)
end
