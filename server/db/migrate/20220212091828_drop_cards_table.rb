class DropCardsTable < ActiveRecord::Migration[6.1]
  def change
    # Deprecated by WkWords, WkKanji, WkRadicals tables
    drop_table :cards
  end
end
