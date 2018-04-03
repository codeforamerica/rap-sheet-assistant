require 'rails_helper'
require 'rap_sheet_parser'

describe ConvictionSentenceBuilder do
  it 'parses jail time' do
    result = described_class.new('006 MONTHS JAIL').build
    expect(result.jail).to eq 6.months
  end

  it 'parses probation time' do
    result = described_class.new('012 MONTHS PROBATION').build
    expect(result.probation).to eq 12.months
  end

  it 'parses prison time' do
    result = described_class.new('012 YEARS PRISON').build
    expect(result.prison).to eq 12.years

    result = described_class.new('012 YEARS PRISON SS').build
    expect(result.prison).to eq nil
  end

  it 'downcases sentence text' do
    result = described_class.new('012 MONTHS PROBATION, 045 DAYS JAIL, FINE').build
    expect(result.to_s).to eq('12m probation, 45d jail, fine')
  end

  it 'removes periods' do
    result = described_class.new('01.2 MONTHS PROBATION').build
    expect(result.probation).to eq 12.months
  end

  it 'removes quotes' do
    result = described_class.new("'006 MONTHS JAIL'").build
    expect(result.jail).to eq 6.months
  end

  it 'removes lines with less than 3 characters' do
    result = described_class.new("FINE SS,\na\nbbb\ncccc").build
    expect(result.to_s).to eq('fine ss, cccc')
  end

  it 'standardizes restitution strings' do
    result = described_class.new('restn, rstn, restitution').build
    expect(result.to_s).to eq('restitution, restitution, restitution')
  end

  it 'replaces newlines with spaces' do
    result = described_class.new("006 MONTHS JAIL,\nFINE").build
    expect(result.to_s).to eq('6m jail, fine')
  end

  it 'replaces newlines with spaces' do
    result = described_class.new("006 MONTHS JAIL,\nFINE").build
    expect(result.to_s).to eq('6m jail, fine')
  end
end
