require 'spec_helper'

require_relative '../../app/domain/sentence_presenter'

describe SentencePresenter do
  it 'downcases sentence text and changes units to single letter' do
    result = SentencePresenter.present(double(text_value: '012 MONTHS PROBATION, 045 DAYS JAIL, FINE'))
    expect(result).to eq('12m probation, 45d jail, fine')
  end

  it 'removes periods' do
    result = SentencePresenter.present(double(text_value: '01.2 MONTHS PROBATION'))
    expect(result).to eq('12m probation')
  end

  it 'removes quotes' do
    result = SentencePresenter.present(double(text_value: "'006 MONTHS JAIL'"))
    expect(result).to eq('6m jail')
  end

  it 'standardizes restitution strings' do
    result = SentencePresenter.present(double(text_value: 'restn, rstn, restitution'))
    expect(result).to eq('restitution, restitution, restitution')
  end

  it 'replaces newlines with spaces' do
    result = SentencePresenter.present(double(text_value: "006 MONTHS JAIL,\nFINE"))
    expect(result).to eq('6m jail, fine')
  end

  it 'replaces newlines with spaces' do
    result = SentencePresenter.present(double(text_value: "006 MONTHS JAIL,\nFINE"))
    expect(result).to eq('6m jail, fine')
  end
end
