require 'spec_helper'
require 'rap_sheet_parser'

describe ArrestEventBuilder do
  it 'populates arrest event' do
    text = <<~TEXT
      info
      * * * *
      ARR/DET/CITE:
      NAM:001
      19910105 CAPD CONCORD
      TOC:F
      CNT:001
      #65131
      496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    event_node = tree.cycles[0].events[0]

    subject = described_class.new(event_node).build

    expect(subject).to be_a ArrestEvent
    expect(subject.date).to eq Date.new(1991, 1, 5)
  end
end
