class AddNotesColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :radicals, :notes, :string
    add_column :kanjis,   :notes, :string
    add_column :words,    :notes, :string
  end
end
