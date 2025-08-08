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

ActiveRecord::Schema[7.1].define(version: 2025_08_08_125147) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "article_views", force: :cascade do |t|
    t.string "user_hash", null: false
    t.bigint "article_id", null: false
    t.integer "count", default: 1, null: false
    t.datetime "last_viewed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_views_on_article_id"
    t.index ["last_viewed_at"], name: "index_article_views_on_last_viewed_at"
    t.index ["user_hash", "article_id"], name: "index_article_views_on_user_hash_and_article_id", unique: true
    t.index ["user_hash"], name: "index_article_views_on_user_hash"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["title"], name: "index_articles_on_title"
  end

  create_table "search_events", force: :cascade do |t|
    t.string "user_hash", null: false
    t.string "session_id", null: false
    t.text "raw_value", null: false
    t.string "event_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_search_events_on_created_at"
    t.index ["event_type"], name: "index_search_events_on_event_type"
    t.index ["session_id"], name: "index_search_events_on_session_id"
    t.index ["user_hash", "session_id"], name: "index_search_events_on_user_hash_and_session_id"
    t.index ["user_hash"], name: "index_search_events_on_user_hash"
  end

  create_table "search_summaries", force: :cascade do |t|
    t.string "user_hash", null: false
    t.string "term", null: false
    t.integer "count", default: 1, null: false
    t.datetime "last_searched_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_searched_at"], name: "index_search_summaries_on_last_searched_at"
    t.index ["term"], name: "index_search_summaries_on_term"
    t.index ["user_hash", "term"], name: "index_search_summaries_on_user_hash_and_term", unique: true
    t.index ["user_hash"], name: "index_search_summaries_on_user_hash"
  end

  add_foreign_key "article_views", "articles"
end
