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

ActiveRecord::Schema.define(:version => 20120219195048) do

  create_table "movies", :force => true do |t|
    t.string   "imdbid"
    t.string   "title"
    t.string   "year"
    t.string   "mpaa_rating"
    t.string   "plot_summary"
    t.string   "plot_details"
    t.string   "poster"
    t.string   "backdrop"
    t.string   "runtime"
    t.string   "rating"
    t.string   "votes"
    t.string   "tmdbid"
    t.string   "imdb_url"
    t.string   "tmdb_url"
    t.string   "pluggedin_url"
    t.string   "kidsinmind_url"
    t.integer  "kim_sex"
    t.integer  "kim_violence"
    t.integer  "kim_language"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "status",         :default => "added"
    t.string   "slug"
  end

  add_index "movies", ["imdbid"], :name => "index_movies_on_imdbid"
  add_index "movies", ["slug"], :name => "index_movies_on_slug", :unique => true
  add_index "movies", ["status"], :name => "index_movies_on_status"

  create_table "subtitles", :force => true do |t|
    t.integer  "start_time"
    t.integer  "end_time"
    t.text     "text"
    t.text     "cleaned_text"
    t.integer  "movie_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "subtitles", ["movie_id"], :name => "index_subtitles_on_movie_id"

end
