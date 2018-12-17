class AddUuidToRapSheets < ActiveRecord::Migration[5.2]
  def up
    add_column :rap_sheets, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :rap_sheet_pages, :rap_sheet_uuid, :uuid

    RapSheetPage.find_each do |page|
      page.rap_sheet_uuid = page.rap_sheet.uuid
      page.save!
    end

    remove_column :rap_sheet_pages, :rap_sheet_id
    rename_column :rap_sheet_pages, :rap_sheet_uuid, :rap_sheet_id

    remove_column :rap_sheets, :id
    rename_column :rap_sheets, :uuid, :id
    execute "ALTER TABLE rap_sheets ADD PRIMARY KEY (id);"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
