require 'rails_helper'

RSpec.describe RapSheet, type: :model do
  before do
    allow_any_instance_of(Parser).to receive(:parse).and_return(nil)
    allow(RapSheetPresenter).to receive(:present).and_return(
      { conviction_counts: [
        instance_double(Count, prop64_eligible?: true),
        instance_double(Count, prop64_eligible?: false)
      ] })
  end

  it 'figures out convictions and stuff' do
    expect(described_class.new.dismissible_convictions.length).to eq(1)
  end
end
