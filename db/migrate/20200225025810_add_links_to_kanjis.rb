class AddLinksToKanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :kanji, :links, :jsonb
  end
end
