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

ActiveRecord::Schema.define(version: 20150905233130) do

  create_table "send_sms", force: :cascade do |t|
    t.string  "momt",       limit: 2
    t.string  "sender",     limit: 20
    t.string  "receiver",   limit: 20
    t.binary  "udhdata",    limit: 65535
    t.text    "msgdata",    limit: 65535
    t.integer "time",       limit: 8
    t.string  "smsc_id",    limit: 255
    t.string  "service",    limit: 255
    t.string  "account",    limit: 255
    t.integer "msg_id",     limit: 8
    t.integer "sms_type",   limit: 8
    t.integer "mclass",     limit: 8
    t.integer "mwi",        limit: 8
    t.integer "coding",     limit: 8
    t.integer "compress",   limit: 8
    t.integer "validity",   limit: 8
    t.integer "deferred",   limit: 8
    t.integer "dlr_mask",   limit: 8
    t.string  "dlr_url",    limit: 255
    t.integer "pid",        limit: 8
    t.integer "alt_dcs",    limit: 8
    t.integer "rpi",        limit: 8
    t.string  "charset",    limit: 255
    t.string  "boxc_id",    limit: 255
    t.string  "binfo",      limit: 255
    t.text    "meta_data",  limit: 65535
    t.string  "foreign_id", limit: 255
  end

  create_table "sent_sms", force: :cascade do |t|
    t.string  "momt",       limit: 2
    t.string  "sender",     limit: 20
    t.string  "receiver",   limit: 20
    t.binary  "udhdata",    limit: 65535
    t.text    "msgdata",    limit: 65535
    t.integer "time",       limit: 8
    t.string  "smsc_id",    limit: 255
    t.string  "service",    limit: 255
    t.string  "account",    limit: 255
    t.integer "msg_id",     limit: 8
    t.integer "sms_type",   limit: 8
    t.integer "mclass",     limit: 8
    t.integer "mwi",        limit: 8
    t.integer "coding",     limit: 8
    t.integer "compress",   limit: 8
    t.integer "validity",   limit: 8
    t.integer "deferred",   limit: 8
    t.integer "dlr_mask",   limit: 8
    t.string  "dlr_url",    limit: 255
    t.integer "pid",        limit: 8
    t.integer "alt_dcs",    limit: 8
    t.integer "rpi",        limit: 8
    t.string  "charset",    limit: 255
    t.string  "boxc_id",    limit: 255
    t.string  "binfo",      limit: 255
    t.text    "meta_data",  limit: 65535
    t.string  "foreign_id", limit: 255
  end

end
