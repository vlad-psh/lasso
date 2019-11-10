class AddSrsProgressTable < ActiveRecord::Migration[6.0]
  def change
    create_table :srs_progresses do |t|
      t.integer :learning_type, default: 0 # 0: kanji->reading/meaning; 1: kana->kanji; 2: audio, 3: grammar?
      t.belongs_to :progress
      t.belongs_to :user
      t.integer :deck
      t.date :scheduled
      t.date :transition
      t.string :last_answer
      t.datetime :reviewed_at
    end

    rename_column :progresses, :deck, :_deck
    rename_column :progresses, :scheduled, :_scheduled
    rename_column :progresses, :transition, :_transition
    rename_column :progresses, :reviewed_at, :_reviewed_at
  end
end
