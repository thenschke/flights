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

ActiveRecord::Schema.define(version: 20171119195950) do

  create_table "communications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "phone_number"
    t.integer "user_id"
    t.integer "offer_id"
    t.string "medium"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "msg_content"
  end

  create_table "offers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "scraper_id"
    t.string "offer_id"
    t.string "from_airport"
    t.string "to_airport"
    t.date "departure"
    t.date "arrival"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source"
  end

  create_table "price_legs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "scraper_id"
    t.integer "price"
    t.string "source"
    t.date "flight_date"
    t.string "from_airport"
    t.string "to_airport"
    t.string "string"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "scraper_id"
    t.string "offer_id"
    t.integer "price"
    t.integer "available_seats"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source"
  end

  create_table "saves", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "offer_id"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrapers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "initiated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "output"
  end

  create_table "sources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "short_name"
    t.string "long_name"
    t.string "url"
    t.string "logo"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "phone_number"
    t.string "nickname"
    t.datetime "last_seen"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
