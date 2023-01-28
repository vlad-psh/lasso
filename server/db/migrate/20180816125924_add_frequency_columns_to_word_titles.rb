class AddFrequencyColumnsToWordTitles < ActiveRecord::Migration[5.2]
  def change
    add_column :word_titles, :is_kanji, :boolean, default: true
    add_column :word_titles, :order, :integer
    add_column :word_titles, :news, :integer
    add_column :word_titles, :ichi, :integer
    add_column :word_titles, :spec, :integer
    add_column :word_titles, :gai,  :integer
    add_column :word_titles, :nf,   :integer
    add_column :word_titles, :is_common, :boolean, default: false
  end
end
