class AddTextToRapSheetPage < ActiveRecord::Migration[5.1]
  def change
    add_column :rap_sheet_pages, :text, :text
  end
end
