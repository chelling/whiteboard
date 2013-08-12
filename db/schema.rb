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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130811231836) do

  create_table "fooicide_picks", :force => true do |t|
    t.integer  "year"
    t.integer  "week"
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "fooicide_picks", ["year", "week", "user_id"], :name => "index_fooicide_picks_on_year_and_week_and_user_id"

  create_table "games", :force => true do |t|
    t.integer  "year"
    t.integer  "week"
    t.string   "location"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.datetime "date"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "line"
  end

  add_index "games", ["year", "week"], :name => "index_games_on_year_and_week"

  create_table "pickem_picks", :force => true do |t|
    t.integer  "year"
    t.integer  "week"
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "win"
  end

  add_index "pickem_picks", ["year", "week", "user_id"], :name => "index_pickem_picks_on_year_and_week_and_user_id"

  create_table "records", :force => true do |t|
    t.integer  "team_id"
    t.integer  "year"
    t.integer  "wins"
    t.integer  "losses"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "records", ["team_id", "year"], :name => "index_records_on_team_id_and_year"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "image"
    t.string   "conference"
    t.string   "division"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "teams", ["conference", "division"], :name => "index_teams_on_conference_and_division"

  create_table "thirty_eights", :force => true do |t|
    t.integer  "year"
    t.integer  "team_id"
    t.integer  "user_id"
    t.integer  "shares"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "thirty_eights", ["year", "user_id"], :name => "index_thirty_eights_on_year_and_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.boolean  "admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
