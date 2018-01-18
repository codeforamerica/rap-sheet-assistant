class CreateRapSheets < ActiveRecord::Migration[5.1]
  def change
    create_table :rap_sheets do |t|
      t.timestamps
    end

    create_table :rap_sheet_pages do |t|
      t.belongs_to :rap_sheet, index: true
      t.string :rap_sheet_page_image

      t.timestamps
    end
  end
end
