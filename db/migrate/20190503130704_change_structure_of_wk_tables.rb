class ChangeStructureOfWkTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :wk_words, :details, :jsonb
    add_column :wk_words, :reading, :string
    add_column :wk_words, :meaning, :string
    add_column :wk_words, :pos, :string
    add_column :wk_words, :mmne, :string
    add_column :wk_words, :rmne, :string
    add_column :wk_words, :sentences, :jsonb

    remove_column :wk_kanji, :details, :jsonb
    add_column :wk_kanji, :meaning, :string
    add_column :wk_kanji, :readings, :jsonb
    add_column :wk_kanji, :mmne, :string
    add_column :wk_kanji, :mhnt, :string
    add_column :wk_kanji, :rmne, :string
    add_column :wk_kanji, :rhnt, :string

    remove_column :wk_radicals, :details, :jsonb
    add_column :wk_radicals, :meaning, :string
    add_column :wk_radicals, :nmne, :string
  end
end
