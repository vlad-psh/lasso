class AddSearchableEngColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :searchable_en, :string
    add_column :words, :searchable_ru, :string
    rename_column :words, :searchable, :searchable_jp
    rename_column :kanji, :searchable, :searchable_en
  end
end
