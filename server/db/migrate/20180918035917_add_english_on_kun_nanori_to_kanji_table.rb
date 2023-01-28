class AddEnglishOnKunNanoriToKanjiTable < ActiveRecord::Migration[5.2]
  def change
    add_column :kanji, :english, :string, array: true
    add_column :kanji, :on,      :string, array: true
    add_column :kanji, :kun,     :string, array: true
    add_column :kanji, :nanori,  :string, array: true
  end
end
