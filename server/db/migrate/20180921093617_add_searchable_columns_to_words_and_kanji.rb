class AddSearchableColumnsToWordsAndKanji < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :searchable, :string
    add_column :kanji, :searchable, :string
  end
end
