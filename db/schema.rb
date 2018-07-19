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

ActiveRecord::Schema.define(version: 2018_07_19_061604) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "action_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["card_id"], name: "index_actions_on_card_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "element_type"
    t.integer "level"
    t.string "title"
    t.jsonb "detailsb"
    t.integer "seq"
  end

  create_table "cards_relations", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "relation_id", null: false
    t.index ["card_id"], name: "index_cards_relations_on_card_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "progresses", force: :cascade do |t|
    t.bigint "card_id"
    t.bigint "user_id"
    t.boolean "unlocked", default: false
    t.boolean "learned", default: false
    t.integer "deck"
    t.date "scheduled"
    t.jsonb "details"
    t.boolean "failed", default: false
    t.index ["card_id"], name: "index_progresses_on_card_id"
    t.index ["user_id"], name: "index_progresses_on_user_id"
  end

  create_table "russian_words", force: :cascade do |t|
    t.string "title"
  end

  create_table "sentences", force: :cascade do |t|
    t.string "japanese"
    t.string "english"
    t.string "russian"
    t.json "structure"
    t.json "details"
  end

  create_table "sentences_words", force: :cascade do |t|
    t.bigint "sentence_id"
    t.bigint "word_id"
    t.index ["sentence_id"], name: "index_sentences_words_on_sentence_id"
    t.index ["word_id"], name: "index_sentences_words_on_word_id"
  end

  create_table "statistics", force: :cascade do |t|
    t.date "date"
    t.jsonb "learned", default: {"k"=>0, "r"=>0, "w"=>0}
    t.jsonb "scheduled", default: {"k"=>0, "r"=>0, "w"=>0}
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "salt"
    t.string "pwhash"
    t.jsonb "settings", default: {}
  end

  create_table "word_connections", id: false, force: :cascade do |t|
    t.integer "long_seq", null: false
    t.integer "short_seq", null: false
    t.index ["long_seq"], name: "index_word_connections_on_long_seq"
    t.index ["short_seq"], name: "index_word_connections_on_short_seq"
  end

  create_table "word_titles", force: :cascade do |t|
    t.integer "seq"
    t.string "title"
  end

  create_table "words", force: :cascade do |t|
    t.integer "seq"
    t.integer "nf"
    t.string "kanji"
    t.integer "card_id"
    t.json "en"
    t.json "ru"
    t.json "kele"
    t.json "rele"
    t.index ["seq"], name: "index_words_on_seq"
  end

end
