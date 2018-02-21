class User < ApplicationRecord
  has_one :rap_sheet

  def full_name
    return unless first_name && last_name

    "#{first_name} #{last_name}"
  end
end
