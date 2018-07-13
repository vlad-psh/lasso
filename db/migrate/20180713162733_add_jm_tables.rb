class AddJmTables < ActiveRecord::Migration[5.2]
  def change
    create_table :jm_elements do |t|
      t.integer :ent_seq
      t.string :title
      t.boolean :is_kanji, default: false

      t.integer :news
      t.integer :ichi
      t.integer :spec
      t.integer :gai
      t.integer :nf
    end

    create_table :jm_meanings do |t|
      t.integer :ent_seq
      t.jsonb :en
      t.jsonb :ru
      t.jsonb :pos
    end
  end
end
