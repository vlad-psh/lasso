class AddKanjiTable < ActiveRecord::Migration[5.2]
  def change
    create_table :kanji do |t|
      t.string :title
      t.integer :jlpt
      t.integer :jlptn
      t.integer :grade
      t.integer :heisig
      t.integer :strokes, array: true # can have many variants
    end

    create_table :kanji_properties do |t|
      t.belongs_to :kanji
      t.string :title
      t.string :extra # suffix, tone, etc
      t.integer :kind
    end
  end
end
