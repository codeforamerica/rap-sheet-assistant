require 'rails_helper'

RSpec.describe RapSheet, type: :model do
  before do
    allow_any_instance_of(Parser).to receive(:parse).and_return(nil)

    conviction_event = ConvictionEvent.new(date: nil, case_number: nil, courthouse: nil, sentence: nil)
    conviction_event.counts = [
      instance_double(ConvictionCount, eligible?: true),
      instance_double(ConvictionCount, eligible?: false)
    ]
    allow(EventCollectionBuilder).to receive(:build).and_return(
      EventCollection.new([conviction_event])
    )
  end

  it 'figures out convictions and stuff' do
    expect(described_class.new.conviction_counts.dismissible.length).to eq(1)
  end
end
