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

ActiveRecord::Schema.define(version: 20180307234809) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "financial_informations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id"
    t.string "job_title"
    t.string "employer_name"
    t.string "employer_address"
    t.boolean "employed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "on_public_benefits"
    t.string "benefits_programs", array: true
    t.index ["user_id"], name: "index_financial_informations_on_user_id"
  end

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
    t.integer "number_of_pages", null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "index_rap_sheets_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "email"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "middle_name"
    t.boolean "on_parole"
    t.boolean "on_probation"
    t.boolean "finished_half_of_probation"
    t.boolean "outstanding_warrant"
    t.boolean "owe_fees"
  end

  add_foreign_key "rap_sheets", "users"
end
