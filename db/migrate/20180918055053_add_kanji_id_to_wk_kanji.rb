class AddKanjiIdToWkKanji < ActiveRecord::Migration[5.2]
  def change
    add_column :wk_kanji, :kanji_id, :bigint
  end
end
