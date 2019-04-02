require 'spec_helper'
require_relative '../../app/domain/pc1203_discretionary_classifier'

describe PC1203DiscretionaryClassifier do
  let(:rap_sheet) { build_rap_sheet(events: [conviction_event]) }

  let (:subject) { PC1203DiscretionaryClassifier.new(event: conviction_event, rap_sheet: rap_sheet) }

  let(:conviction_event) do
    build_court_event(
      date: date,
      counts: [build_count(dispositions: [build_disposition(severity: severity, sentence: sentence, date: Date.today - 3.years)])]
    )
  end

  describe '#eligible?' do
    context 'the underlying conviction is not 1203 eligible' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: 1.year, probation: nil) }
      let(:severity) { 'F' }
      let(:date) { Date.today - 3.years }

      it 'returns false' do
        expect(subject.eligible?).to be false
      end
    end

    context 'the underlying conviction is eligible for mandatory 1203' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.year) }
        let(:severity) { 'M' }
        let(:date) { Date.today - 3.years }

        it 'returns false' do
          expect(subject.eligible?).to be false
        end
    end

    context 'the underlying conviction is eligible for discretionary 1203' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year) }
      let(:severity) { 'F' }
      let(:date) { Date.today - 4.years }

      it 'returns true' do
        expect(subject.eligible?).to be true
      end
    end
  end
end
