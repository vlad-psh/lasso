class AddPitchAccentsToWordTitles < ActiveRecord::Migration[6.0]
  def change
    add_column :word_titles, :pitch, :string
  end
end
