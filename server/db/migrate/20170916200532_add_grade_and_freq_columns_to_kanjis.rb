class AddGradeAndFreqColumnsToKanjis < ActiveRecord::Migration[5.1]
  def change
    add_column :kanjis, :grade, :integer
    add_column :kanjis, :freq, :integer
  end
end
