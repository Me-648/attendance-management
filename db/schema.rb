# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_05_123000) do
  create_table "attendances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "period_id", null: false
    t.text "reason"
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["period_id"], name: "index_attendances_on_period_id"
    t.index ["user_id", "period_id", "date"], name: "index_attendances_on_user_period_date", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "period_number"
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.integer "weekday"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "enrollment_year"
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", null: false
    t.string "student_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["student_id"], name: "index_users_on_student_id", unique: true, where: "student_id IS NOT NULL"
  end

  add_foreign_key "attendances", "periods"
  add_foreign_key "attendances", "users"
end
