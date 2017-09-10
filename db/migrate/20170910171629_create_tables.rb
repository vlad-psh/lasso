class CreateTables < ActiveRecord::Migration[5.1]
  def change
    create_table :radicals do |t|
      t.integer :level
      t.string :title
      t.string :en
      t.json :details #nmne, nhnt
    end
    create_table :kanjis do |t|
      t.integer :level
      t.string :title
      t.string :en, array: true
      t.json :yomi
      t.json :details #mmne, mhnt, rmne, rhnt
      t.string :similar, array: true
    end
    create_table :words do |t|
      t.integer :level
      t.string :title
      t.string :en, array: true
      t.string :pos
      t.string :readings, array: true
      t.json :sentences
      t.json :details #mexp, rexp
    end
    create_table :kanjis_radicals do |t|
      t.belongs_to :kanji
      t.belongs_to :radical
    end
    create_table :kanjis_words do |t|
      t.belongs_to :kanji
      t.belongs_to :word
    end
  end
end
