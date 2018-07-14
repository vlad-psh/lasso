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

ActiveRecord::Schema.define(version: 2018_07_14_161450) do

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
    t.integer "ent_seq"
  end

  create_table "cards_relations", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "relation_id", null: false
    t.index ["card_id"], name: "index_cards_relations_on_card_id"
  end

  create_table "jm_elements", force: :cascade do |t|
    t.integer "ent_seq"
    t.string "title"
    t.boolean "is_kanji", default: false
    t.integer "news"
    t.integer "ichi"
    t.integer "spec"
    t.integer "gai"
    t.integer "nf"
    t.index ["ent_seq"], name: "index_jm_elements_on_ent_seq"
    t.index ["title"], name: "index_jm_elements_on_title"
  end

  create_table "jm_meanings", force: :cascade do |t|
    t.integer "ent_seq"
    t.jsonb "en"
    t.jsonb "ru"
    t.jsonb "pos"
    t.integer "nf"
    t.index ["ent_seq"], name: "index_jm_meanings_on_ent_seq"
  end

  create_table "notes", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "russian_words", force: :cascade do |t|
    t.string "title"
  end

  create_table "statistics", force: :cascade do |t|
    t.date "date"
    t.jsonb "learned", default: {"k"=>0, "r"=>0, "w"=>0}
    t.jsonb "scheduled", default: {"k"=>0, "r"=>0, "w"=>0}
    t.integer "user_id"
  end

  create_table "user_cards", force: :cascade do |t|
    t.bigint "card_id"
    t.bigint "user_id"
    t.boolean "unlocked", default: false
    t.boolean "learned", default: false
    t.integer "deck"
    t.date "scheduled"
    t.jsonb "details"
    t.boolean "failed", default: false
    t.index ["card_id"], name: "index_user_cards_on_card_id"
    t.index ["user_id"], name: "index_user_cards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "salt"
    t.string "pwhash"
    t.jsonb "settings", default: {}
  end

end
