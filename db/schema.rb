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

ActiveRecord::Schema.define(version: 2018_07_29_233600) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.bigint "pool_id"
    t.bigint "user_id"
    t.string "name"
    t.integer "teams", default: [], null: false, array: true
    t.integer "status"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pool_id"], name: "index_entries_on_pool_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "game_pools", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "pool_id"
    t.integer "week"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_pools_on_game_id"
    t.index ["pool_id"], name: "index_game_pools_on_pool_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "home_team"
    t.integer "away_team"
    t.integer "status"
    t.integer "winner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "loser"
    t.integer "week"
    t.integer "year"
  end

  create_table "pools", force: :cascade do |t|
    t.integer "week"
    t.integer "year"
    t.text "description"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "entries", "pools"
  add_foreign_key "entries", "users"
  add_foreign_key "game_pools", "games"
  add_foreign_key "game_pools", "pools"
end
