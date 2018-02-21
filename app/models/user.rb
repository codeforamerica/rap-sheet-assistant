class User < ApplicationRecord
  has_one :rap_sheet

  def full_name
    return unless [first_name, last_name].all?(&:present?)

    [first_name, middle_name, last_name].select(&:present?).join(' ')
  end
end
