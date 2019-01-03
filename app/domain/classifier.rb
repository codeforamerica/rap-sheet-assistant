module Classifier
  def initialize(event:, rap_sheet:)
    @event = event
    @rap_sheet = rap_sheet
  end

  private

  attr_reader :event, :rap_sheet
end
