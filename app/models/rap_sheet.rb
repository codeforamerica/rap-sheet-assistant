class RapSheet < ApplicationRecord
  belongs_to :user

  has_many :rap_sheet_pages

  validates :number_of_pages, numericality: {
    only_integer: true,
    less_than: 100,
    greater_than_or_equal_to: 1
  }

  def text
    rap_sheet_pages.map(&:text).join
  end

  def first_missing_page_number
    ((1..number_of_pages).to_a - rap_sheet_pages.pluck(:page_number)).first
  end

  def all_pages_uploaded?
    rap_sheet_pages.length == number_of_pages
  end

  def parsed
    @parsed ||= RapSheetParser::Parser.new.parse(text)
    if @parsed.personal_info
      unless user.name.present? && user.date_of_birth.present?
        user.update!(name: @parsed.personal_info.names.first.second, date_of_birth: @parsed.personal_info.date_of_birth)
        user.format_name
      end
    end
    @parsed
  end
end
