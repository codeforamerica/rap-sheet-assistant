class User < ApplicationRecord
  has_one :rap_sheet
  has_one :financial_information
  belongs_to :attorney, optional: true
end
