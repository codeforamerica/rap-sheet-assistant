class RapSheet < ApplicationRecord
  has_many :rap_sheet_pages, as: :pages
end
