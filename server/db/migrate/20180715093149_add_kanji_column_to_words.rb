class AddKanjiColumnToWords < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :kanji, :string
  end
end
