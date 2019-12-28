class AddKanjiReadingsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :kanji_readings do |t|
      t.string :title
      t.string :reading
      t.integer :kind
    end
  end
end
