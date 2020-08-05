class AddSimilarsToKanjis < ActiveRecord::Migration[6.0]
  def change
    add_column :kanji, :similars, :jsonb
  end
end
