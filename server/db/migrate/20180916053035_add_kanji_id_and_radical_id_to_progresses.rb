class AddKanjiIdAndRadicalIdToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :kanji_id, :integer
    add_column :progresses, :wk_radical_id, :integer
  end
end
