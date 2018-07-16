class AddSentencesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :sentences do |t|
      t.json :value
    end

    create_table :sentences_words do |t|
      t.belongs_to :sentence
      t.belongs_to :word
    end
  end
end
