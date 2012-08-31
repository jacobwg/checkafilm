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

ActiveRecord::Schema.define(:version => 20120831183807) do

  create_table "backdrops", :force => true do |t|
    t.string   "image"
    t.string   "original_url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "title_id"
  end

  create_table "titles", :force => true do |t|
    t.string   "name"
    t.text     "plot_summary"
    t.text     "plot_details"
    t.string   "mpaa_rating"
    t.date     "release_date"
    t.float    "imdb_rating"
    t.integer  "imdb_votes"
    t.string   "imdb_id"
    t.string   "tmdb_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "runtime"
    t.float    "tmdb_rating"
    t.integer  "tmdb_votes"
    t.string   "poster"
    t.string   "original_poster_url"
    t.string   "slug"
    t.date     "release_date_dvd"
    t.string   "homepage"
    t.float    "rotten_tomatoes_critics_score"
    t.float    "rotten_tomatoes_audience_score"
    t.string   "rotten_tomatoes_audience_rating"
    t.string   "rotten_tomatoes_critics_rating"
    t.string   "rotten_tomatoes_critics_consensus"
    t.string   "rotten_tomatoes_link"
    t.string   "imdb_link"
    t.string   "tmdb_link"
    t.string   "kids_in_mind_link"
    t.string   "plugged_in_link"
    t.integer  "kids_in_mind_sex_number"
    t.integer  "kids_in_mind_language_number"
    t.integer  "kids_in_mind_violence_number"
    t.string   "status_state"
    t.text     "plugged_in_review"
  end

  add_index "titles", ["slug"], :name => "index_titles_on_slug", :unique => true

  create_table "trailers", :force => true do |t|
    t.string   "url"
    t.integer  "title_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "name"
    t.string   "thumbnail"
    t.string   "original_thumbnail_url"
  end

end
