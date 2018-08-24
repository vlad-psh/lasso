class AddFlaggedToWordDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :word_details, :flagged, :boolean, default: false
  end
end
