class AddPageNumberToRapSheetPage < ActiveRecord::Migration[5.1]
  class RapSheet < ApplicationRecord
    has_many :rap_sheet_pages
  end

  class RapSheetPage < ApplicationRecord; end

  def up
    add_column :rap_sheet_pages, :page_number, :int

    RapSheet.all.each do |rap_sheet|
      rap_sheet.rap_sheet_pages.order(created_at: :asc).each_with_index do |page, index|
        page.update!(page_number: index)
      end
    end

    change_column_null :rap_sheet_pages, :page_number, false
  end

  def down
    remove_column :rap_sheet_pages, :page_number
  end
end
