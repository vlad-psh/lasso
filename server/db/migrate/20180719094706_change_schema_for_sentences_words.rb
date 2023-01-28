class ChangeSchemaForSentencesWords < ActiveRecord::Migration[5.2]
  def change
    remove_column :sentences_words, :word_id, :integer
    add_column :sentences_words, :word_seq, :integer
    add_index :sentences_words, :word_seq
  end
end
