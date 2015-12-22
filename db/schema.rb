# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151218123524) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string "locale",   limit: 5,  null: false
    t.string "language", limit: 20, null: false
  end

  create_table "sms_campaigns", force: :cascade do |t|
    t.integer  "user_id",        limit: 4,                                              null: false
    t.integer  "account_id",     limit: 4
    t.string   "label",          limit: 64
    t.string   "originator",     limit: 20
    t.text     "msg_body",       limit: 65535
    t.string   "timezone",       limit: 60,                             default: "UTC", null: false
    t.integer  "start_date",     limit: 8
    t.integer  "end_date",       limit: 8
    t.integer  "encoding",       limit: 8
    t.integer  "on_screen",      limit: 8
    t.integer  "total_sms",      limit: 8
    t.integer  "sent_to_box",    limit: 8,                              default: 0
    t.boolean  "finished",                                              default: false
    t.integer  "state",          limit: 1,                              default: 0,                  comment: "0: scheduled, 1: started, 2: paused, 3: stopped, 4: archieved"
    t.decimal  "estimated_cost",               precision: 10, scale: 5
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
  end

  add_index "sms_campaigns", ["user_id"], name: "idx_sms_campaigns_user_id", using: :btree

  create_table "sms_recipient_lists", id: false, force: :cascade do |t|
    t.integer "sms_campaign_id", limit: 4,     null: false
    t.text    "contacts",        limit: 65535,              comment: "Array of phone numbers and/or contact ids"
    t.text    "contact_groups",  limit: 65535,              comment: "Array of contact_group ids"
  end

  add_index "sms_recipient_lists", ["sms_campaign_id"], name: "idx_sms_recipient_lists_campaign_id", using: :btree

  create_table "sms_restricted_time_ranges", force: :cascade do |t|
    t.integer "sms_campaign_id", limit: 4, null: false
    t.time    "start_time"
    t.time    "end_time"
  end

  add_index "sms_restricted_time_ranges", ["sms_campaign_id"], name: "idx_sms_restricted_time_ranges_campaign_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,     default: 0,  null: false
    t.datetime "locked_at"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "metadata",               limit: 65535
    t.integer  "language_id",            limit: 4,     default: 1
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["language_id"], name: "index_users_on_language_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "sms_campaigns", "users", on_update: :cascade
  add_foreign_key "sms_recipient_lists", "sms_campaigns", on_delete: :cascade
  add_foreign_key "sms_restricted_time_ranges", "sms_campaigns", on_delete: :cascade
  add_foreign_key "users", "languages"
end
