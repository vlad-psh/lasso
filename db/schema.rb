# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_10_113236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "action_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "progress_id"
    t.bigint "srs_progress_id"
    t.index ["card_id"], name: "index_actions_on_card_id"
    t.index ["srs_progress_id"], name: "index_actions_on_srs_progress_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "element_type"
    t.integer "level"
    t.string "title"
    t.jsonb "detailsb"
    t.integer "seq"
    t.boolean "is_disabled", default: false
  end

  create_table "cards_relations", force: :cascade do |t|
    t.bigint "card_id"
    t.integer "relation_id", null: false
    t.index ["card_id"], name: "index_cards_relations_on_card_id"
  end

  create_table "drills", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id"
    t.datetime "created_at"
    t.boolean "is_active", default: true
    t.index ["user_id"], name: "index_drills_on_user_id"
  end

  create_table "drills_progresses", force: :cascade do |t|
    t.bigint "drill_id"
    t.bigint "progress_id"
    t.datetime "created_at"
    t.index ["drill_id"], name: "index_drills_progresses_on_drill_id"
    t.index ["progress_id"], name: "index_drills_progresses_on_progress_id"
  end

  create_table "kanji", force: :cascade do |t|
    t.string "title"
    t.integer "jlpt"
    t.integer "jlptn"
    t.integer "grade"
    t.integer "heisig"
    t.integer "strokes", array: true
    t.string "english", array: true
    t.string "on", array: true
    t.string "kun", array: true
    t.string "nanori", array: true
    t.string "searchable_en"
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
    t.integer "_deck"
    t.date "_scheduled"
    t.jsonb "details"
    t.integer "seq"
    t.datetime "learned_at"
    t.datetime "burned_at"
    t.string "title"
    t.integer "kanji_id"
    t.integer "wk_radical_id"
    t.date "_transition"
    t.datetime "flagged_at"
    t.datetime "_reviewed_at"
    t.index ["card_id"], name: "index_progresses_on_card_id"
    t.index ["seq"], name: "index_progresses_on_seq"
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
    t.datetime "created_at"
  end

  create_table "sentences_words", force: :cascade do |t|
    t.bigint "sentence_id"
    t.integer "word_seq"
    t.index ["sentence_id"], name: "index_sentences_words_on_sentence_id"
    t.index ["word_seq"], name: "index_sentences_words_on_word_seq"
  end

  create_table "srs_progresses", force: :cascade do |t|
    t.integer "learning_type", default: 0
    t.bigint "progress_id"
    t.bigint "user_id"
    t.integer "deck"
    t.date "scheduled"
    t.date "transition"
    t.string "last_answer"
    t.datetime "reviewed_at"
    t.integer "kind"
    t.index ["progress_id"], name: "index_srs_progresses_on_progress_id"
    t.index ["user_id"], name: "index_srs_progresses_on_user_id"
  end

  create_table "statistics", force: :cascade do |t|
    t.date "date"
    t.jsonb "learned", default: {"k"=>0, "r"=>0, "w"=>0}
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "salt"
    t.string "pwhash"
    t.jsonb "settings", default: {}
  end

  create_table "wk_kanji", force: :cascade do |t|
    t.integer "level"
    t.string "title"
    t.bigint "kanji_id"
    t.integer "wk_internal_id"
    t.string "meaning"
    t.jsonb "readings"
    t.string "mmne"
    t.string "mhnt"
    t.string "rmne"
    t.string "rhnt"
  end

  create_table "wk_kanji_radicals", id: false, force: :cascade do |t|
    t.bigint "wk_kanji_id"
    t.bigint "wk_radical_id"
    t.index ["wk_kanji_id"], name: "index_wk_kanji_radicals_on_wk_kanji_id"
    t.index ["wk_radical_id"], name: "index_wk_kanji_radicals_on_wk_radical_id"
  end

  create_table "wk_kanji_words", id: false, force: :cascade do |t|
    t.bigint "wk_kanji_id"
    t.bigint "wk_word_id"
    t.index ["wk_kanji_id"], name: "index_wk_kanji_words_on_wk_kanji_id"
    t.index ["wk_word_id"], name: "index_wk_kanji_words_on_wk_word_id"
  end

  create_table "wk_radicals", force: :cascade do |t|
    t.integer "level"
    t.string "title"
    t.integer "wk_internal_id"
    t.string "meaning"
    t.string "nmne"
    t.string "svg"
  end

  create_table "wk_words", force: :cascade do |t|
    t.integer "level"
    t.string "title"
    t.integer "seq"
    t.integer "wk_internal_id"
    t.string "reading"
    t.string "meaning"
    t.string "pos"
    t.string "mmne"
    t.string "rmne"
    t.jsonb "sentences"
  end

  create_table "word_details", force: :cascade do |t|
    t.integer "seq"
    t.integer "user_id"
    t.string "comment"
  end

  create_table "word_titles", force: :cascade do |t|
    t.integer "seq"
    t.string "title"
    t.boolean "is_kanji", default: true
    t.integer "order"
    t.integer "news"
    t.integer "ichi"
    t.integer "spec"
    t.integer "gai"
    t.integer "nf"
    t.boolean "is_common", default: false
  end

  create_table "words", force: :cascade do |t|
    t.integer "seq"
    t.integer "nf"
    t.string "kanji"
    t.json "en"
    t.json "ru"
    t.boolean "is_common"
    t.jsonb "kebs"
    t.jsonb "rebs"
    t.integer "jlptn"
    t.string "searchable_jp"
    t.string "searchable_en"
    t.string "searchable_ru"
    t.index ["seq"], name: "index_words_on_seq"
  end

end
