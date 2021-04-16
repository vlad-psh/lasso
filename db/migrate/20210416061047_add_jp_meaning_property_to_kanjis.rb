class AddJpMeaningPropertyToKanjis < ActiveRecord::Migration[6.1]
  def change
    add_column :kanji, :jp, :string
    add_column :kanji, :jp_url, :string
  end
end
