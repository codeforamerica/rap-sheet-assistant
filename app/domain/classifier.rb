module Classifier
  def initialize(user:, event:, rap_sheet:)
    @user = user
    @event = event
    @rap_sheet = rap_sheet
  end

  private

  attr_reader :event, :rap_sheet, :user
end
