class AddCardIdToKanji < ActiveRecord::Migration[5.2]
  def change
    add_column :kanji, :card_id, :integer
    add_column :kanji, :wk, :integer
  end
end
