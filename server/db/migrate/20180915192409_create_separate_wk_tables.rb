class CreateSeparateWkTables < ActiveRecord::Migration[5.2]
  def change
    create_table :wk_words do |t|
      t.integer :level
      t.string  :title
      t.jsonb   :details
      t.integer :seq
    end

    create_table :wk_kanji do |t|
      t.integer :level
      t.string  :title
      t.jsonb   :details
    end

    create_table :wk_radicals do |t|
      t.integer :level
      t.string  :title
      t.jsonb   :details
    end

    create_table :wk_kanji_radicals, id: false do |t|
      t.belongs_to :wk_kanji
      t.belongs_to :wk_radical
    end

    create_table :wk_kanji_words, id: false do |t|
      t.belongs_to :wk_kanji
      t.belongs_to :wk_word
    end
  end
end
