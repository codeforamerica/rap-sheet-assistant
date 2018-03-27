require 'spec_helper'
require_relative '../../parser/lib/text_cleaner'

describe TextCleaner do
  describe '.clean' do
    it 'replaces commonly mis-scanned text' do
      expect(clean('FOO ÇNT: FOO')).to eq('FOO CNT: FOO')
      expect(clean('WRONG–DASH')).to eq('WRONG-DASH')
      expect(clean('CNI: HI')).to eq('CNT: HI')
    end

    it 'upcases all text' do
      expect(clean('abcD')).to eq 'ABCD'
    end
  end
end

def clean(text)
  TextCleaner.clean(text)
end
