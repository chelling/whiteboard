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

ActiveRecord::Schema.define(version: 20140706191709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "year"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "fooicide_picks", force: :cascade do |t|
    t.integer  "year"
    t.integer  "week"
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "win"
  end

  add_index "fooicide_picks", ["year", "week", "user_id"], name: "index_fooicide_picks_on_year_and_week_and_user_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "year"
    t.integer  "week"
    t.string   "location"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "line"
  end

  add_index "games", ["year", "week"], name: "index_games_on_year_and_week", using: :btree

  create_table "pickem_picks", force: :cascade do |t|
    t.integer  "year"
    t.integer  "week"
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "win"
    t.boolean  "tie"
    t.boolean  "recommended"
    t.integer  "recommended_points"
  end

  add_index "pickem_picks", ["year", "week", "user_id"], name: "index_pickem_picks_on_year_and_week_and_user_id", using: :btree

  create_table "records", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "year"
    t.integer  "wins"
    t.integer  "losses"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "records", ["team_id", "year"], name: "index_records_on_team_id_and_year", using: :btree

  create_table "shares", force: :cascade do |t|
    t.integer  "year"
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shares", ["user_id", "team_id", "game_id"], name: "index_shares_on_user_id_and_team_id_and_game_id", using: :btree

  create_table "stadiums", force: :cascade do |t|
    t.integer  "team_id"
    t.string   "location"
    t.string   "time_zone"
    t.string   "stadium_type"
    t.string   "grass_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "location"
    t.string   "image"
    t.string   "conference"
    t.string   "division"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["conference", "division"], name: "index_teams_on_conference_and_division", using: :btree

  create_table "thirty_eights", force: :cascade do |t|
    t.integer  "year"
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "shares"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thirty_eights", ["year", "user_id"], name: "index_thirty_eights_on_year_and_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wagers", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "pickem_pick_id"
    t.decimal  "amount"
    t.decimal  "potential_payout"
    t.decimal  "payout"
    t.integer  "win"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "previous_amount"
  end

  add_index "wagers", ["account_id", "pickem_pick_id"], name: "index_wagers_on_account_id_and_pickem_pick_id", using: :btree

  create_table "win_pool_leagues", force: :cascade do |t|
    t.string   "name"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "win_pool_leagues", ["year"], name: "index_win_pool_leagues_on_year", using: :btree

  create_table "win_pool_picks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "win_pool_league_id"
    t.integer  "starting_position"
    t.integer  "year"
    t.integer  "team_one_id"
    t.integer  "team_two_id"
    t.integer  "team_three_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "win_pool_picks", ["win_pool_league_id", "user_id", "year"], name: "index_win_pool_picks_on_win_pool_league_id_and_user_id_and_year", using: :btree

end
