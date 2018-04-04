module Classifier
  def initialize(user:, event:, event_collection:)
    @user = user
    @event = event
    @event_collection = event_collection
  end

  private

  attr_reader :event, :event_collection, :user
end
