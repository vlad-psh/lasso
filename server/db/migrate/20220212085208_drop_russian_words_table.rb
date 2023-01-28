class DropRussianWordsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :russian_words
  end
end
