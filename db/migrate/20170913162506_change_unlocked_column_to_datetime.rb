class ChangeUnlockedColumnToDatetime < ActiveRecord::Migration[5.1]
  def change
    add_column :radicals, :unlocked_at, :datetime, default: nil
    add_column :kanjis,   :unlocked_at, :datetime, default: nil
    add_column :words,    :unlocked_at, :datetime, default: nil

    add_column :radicals, :learned_at, :datetime, default: nil
    add_column :kanjis,   :learned_at, :datetime, default: nil
    add_column :words,    :learned_at, :datetime, default: nil

    remove_column :radicals, :unlocked
    remove_column :kanjis,   :unlocked
    remove_column :words,    :unlocked
  end
end
