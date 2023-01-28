class RemoveFlaggedColumnFromProgresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :progresses, :flagged, :boolean, default: false
  end
end
