class DropKanjiPropertiesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :kanji_properties
  end
end
