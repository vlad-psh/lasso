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

ActiveRecord::Schema.define(version: 20170919070006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "action_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_actions_on_card_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "element_type"
    t.integer "level"
    t.string "title"
    t.json "details"
    t.boolean "unlocked", default: false
    t.boolean "learned", default: false
    t.integer "deck"
    t.date "scheduled"
    t.jsonb "detailsb"
  end

  create_table "cards_relations", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "relation_id", null: false
    t.index ["card_id"], name: "index_cards_relations_on_card_id"
  end

  create_table "kanjis", force: :cascade do |t|
    t.integer "level"
    t.string "title"
    t.string "en", array: true
    t.json "yomi"
    t.json "details"
    t.string "similar", array: true
    t.integer "deck", default: 0
    t.integer "passes", default: 0
    t.integer "fails", default: 0
    t.date "reviewed"
    t.date "scheduled"
    t.datetime "unlocked_at"
    t.datetime "learned_at"
    t.integer "grade"
    t.integer "freq"
    t.string "notes"
    t.index ["title"], name: "index_kanjis_on_title"
  end

  create_table "kanjis_radicals", force: :cascade do |t|
    t.bigint "kanji_id"
    t.bigint "radical_id"
    t.index ["kanji_id"], name: "index_kanjis_radicals_on_kanji_id"
    t.index ["radical_id"], name: "index_kanjis_radicals_on_radical_id"
  end

  create_table "kanjis_words", force: :cascade do |t|
    t.bigint "kanji_id"
    t.bigint "word_id"
    t.index ["kanji_id"], name: "index_kanjis_words_on_kanji_id"
    t.index ["word_id"], name: "index_kanjis_words_on_word_id"
  end

  create_table "radicals", force: :cascade do |t|
    t.integer "level"
    t.string "title"
    t.string "en"
    t.json "details"
    t.integer "deck", default: 0
    t.integer "passes", default: 0
    t.integer "fails", default: 0
    t.date "reviewed"
    t.date "scheduled"
    t.datetime "unlocked_at"
    t.datetime "learned_at"
    t.string "notes"
    t.index ["en"], name: "index_radicals_on_en"
  end

  create_table "words", force: :cascade do |t|
    t.integer "level"
    t.string "title"
    t.string "en", array: true
    t.string "pos"
    t.string "readings", array: true
    t.json "sentences"
    t.json "details"
    t.integer "deck", default: 0
    t.integer "passes", default: 0
    t.integer "fails", default: 0
    t.date "reviewed"
    t.date "scheduled"
    t.datetime "unlocked_at"
    t.datetime "learned_at"
    t.string "notes"
  end

end
