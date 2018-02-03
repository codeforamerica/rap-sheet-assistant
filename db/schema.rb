# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180203002719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rap_sheet_pages", force: :cascade do |t|
    t.bigint "rap_sheet_id"
    t.string "rap_sheet_page_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.integer "page_number", null: false
    t.index ["rap_sheet_id"], name: "index_rap_sheet_pages_on_rap_sheet_id"
  end

  create_table "rap_sheets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
