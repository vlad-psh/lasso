class AddSentencesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :sentences do |t|
      t.string :japanese
      t.string :english
      t.string :russian
      t.json :structure
      t.json :details
    end

    create_table :sentences_words do |t|
      t.belongs_to :sentence
      t.belongs_to :word
    end
  end
end
