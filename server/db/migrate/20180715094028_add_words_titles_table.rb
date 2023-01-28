class AddWordsTitlesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :word_titles do |t|
      t.integer :seq
      t.string :title
    end
    rename_column :words, :ent_seq, :seq
    rename_column :cards, :ent_seq, :seq
  end
end
