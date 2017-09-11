class CreateTables < ActiveRecord::Migration[5.1]
  def change
    create_table :radicals do |t|
      t.integer :level
      t.string :title
      t.string :en, unique: true, index: true
      t.json :details #nmne, nhnt

      t.boolean :unlocked, default: false
      t.integer :deck, default: 0
      t.integer :passes, default: 0
      t.integer :fails, default: 0
      t.date :reviewed
      t.date :scheduled
    end

    create_table :kanjis do |t|
      t.integer :level
      t.string :title, unique: true, index: true
      t.string :en, array: true
      t.json :yomi
      t.json :details #mmne, mhnt, rmne, rhnt
      t.string :similar, array: true

      t.boolean :unlocked, default: false
      t.integer :deck, default: 0
      t.integer :passes, default: 0
      t.integer :fails, default: 0
      t.date :reviewed
      t.date :scheduled
    end

    create_table :words do |t|
      t.integer :level
      t.string :title
      t.string :en, array: true
      t.string :pos
      t.string :readings, array: true
      t.json :sentences
      t.json :details #mexp, rexp

      t.boolean :unlocked, default: false
      t.integer :deck, default: 0
      t.integer :passes, default: 0
      t.integer :fails, default: 0
      t.date :reviewed
      t.date :scheduled
    end

    create_table :kanjis_radicals do |t|
      t.belongs_to :kanji, index: true
      t.belongs_to :radical, index: true
    end

    create_table :kanjis_words do |t|
      t.belongs_to :kanji, index: true
      t.belongs_to :word, index: true
    end
  end
end
