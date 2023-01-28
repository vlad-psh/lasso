class AddFlaggedToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :flagged, :boolean, default: false
  end
end
