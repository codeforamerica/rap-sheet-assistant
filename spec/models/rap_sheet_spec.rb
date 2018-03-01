require 'rails_helper'

RSpec.describe RapSheet, type: :model do
  before do
    allow_any_instance_of(Parser).to receive(:parse).and_return(nil)
    allow(RapSheetPresenter).to receive(:present).and_return([
      instance_double(ConvictionEvent,
        counts: [
          instance_double(ConvictionCount, eligible?: true),
          instance_double(ConvictionCount, eligible?: false)
        ]
      )
    ])
  end

  it 'figures out convictions and stuff' do
    expect(described_class.new.conviction_counts.dismissible.length).to eq(1)
  end
end
