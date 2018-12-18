class AddUuidToRapSheetPages < ActiveRecord::Migration[5.2]
  def up
    add_column :rap_sheet_pages, :uuid, :uuid, default: "gen_random_uuid()", null: false

    remove_column :rap_sheet_pages, :id
    rename_column :rap_sheet_pages, :uuid, :id

    execute "ALTER TABLE rap_sheet_pages ADD PRIMARY KEY (id);"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
