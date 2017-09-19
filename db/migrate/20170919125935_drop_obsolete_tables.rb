class DropObsoleteTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :radicals
    drop_table :kanjis
    drop_table :words
    drop_table :kanjis_radicals
    drop_table :kanjis_words
    remove_column :cards, :details
  end
end
