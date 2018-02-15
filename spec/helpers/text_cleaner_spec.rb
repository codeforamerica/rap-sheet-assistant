require 'spec_helper'
require_relative '../../app/helpers/text_cleaner'

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

    it 'strips lines with few characters' do
      dirty_text = <<~TEXT
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        T
        E
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
        S
        S
      TEXT

      clean_text = <<~TEXT
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      expect(clean(dirty_text.strip)).to eq(clean_text.strip)
    end
  end
end

def clean(text)
  TextCleaner.clean(text)
end
