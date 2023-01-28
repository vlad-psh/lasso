class AddQtypeToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :kind, :integer # enum: word, kanji, radical (etc?)
  end
end
