class AddJradicalToKanji < ActiveRecord::Migration[6.0]
  def change
    add_column :kanji, :radnum, :integer
  end
end
