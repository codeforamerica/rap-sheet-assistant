class User < ApplicationRecord
  has_one :rap_sheet
  has_one :financial_information
  belongs_to :attorney, optional: true

  def format_name
    name_array = name.split(',')
    formatted_name = name_array[1] + ' ' + name_array[0]
    update!(name: formatted_name)
  end
end
