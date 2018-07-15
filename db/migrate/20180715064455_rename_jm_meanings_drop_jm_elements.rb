class RenameJmMeaningsDropJmElements < ActiveRecord::Migration[5.2]
  def change
    rename_table :jm_meanings, :words
    drop_table :jm_elements
  end
end
