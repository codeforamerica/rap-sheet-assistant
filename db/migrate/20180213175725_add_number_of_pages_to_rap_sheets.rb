class AddNumberOfPagesToRapSheets < ActiveRecord::Migration[5.1]
  class RapSheet < ApplicationRecord
    has_many :rap_sheet_pages
  end

  def up
    add_column :rap_sheets, :number_of_pages, :integer

    RapSheet.all.each do |rap_sheet|
      rap_sheet.update!(number_of_pages: rap_sheet.rap_sheet_pages.count)
    end

    change_column_null :rap_sheets, :number_of_pages, false
  end

  def down
    remove_column :rap_sheets, :number_of_pages
  end
end
