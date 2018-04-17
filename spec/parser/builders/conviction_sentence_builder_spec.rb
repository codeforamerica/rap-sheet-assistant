require 'rails_helper'
require 'rap_sheet_parser'

describe ConvictionSentenceBuilder do
  it 'parses jail time' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      SEN: 006 MONTHS JAIL
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.jail).to eq 6.months
  end

  it 'parses probation time' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      SEN: 012 MONTHS PROBATION
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.probation).to eq 12.months
  end

  it 'parses prison time' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      SEN: 012 YEARS PRISON
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.prison).to eq 12.years
  end

  it 'parses times from comments' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      COM: SEN-X24 MO PROB, 8 DS JL, RSTN
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    result = described_class.new(sentence_node).build
    expect(result.probation).to eq 24.months
    expect(result.jail).to eq 8.days

    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      COM: SEN-X3 YR PROB
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.probation).to eq 3.years
  end

  it 'downcases details' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      SEN: 012 YEARS PRISON, FINE, FINE SS
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.to_s).to eq('12y prison, fine, fine ss')
  end

  it 'standardizes restitution strings' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      SEN: RESTN, RSTN, RESTITUTION
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.to_s).to eq('restitution, restitution, restitution')
  end

  it 'cleans up common strings' do
    text = <<~TEXT
      info
      * * * *
      COURT:
      19941120 CASC SAN DIEGO

      CNT: 001 #612
      487.2 PC-GRAND THEFT FROM PERSON
      DISPO:CONVICTED
      CONV STATUS:MISDEMEANOR
      SEN: BL FINE SS AH, CONCURRENT B A
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    sentence_node = tree.cycles[0].events[0].sentence
    expect(described_class.new(sentence_node).build.to_s).to eq('fine ss, concurrent')
  end
end
