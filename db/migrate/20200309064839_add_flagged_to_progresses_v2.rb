class AddFlaggedToProgressesV2 < ActiveRecord::Migration[6.0]
  def change
    add_column :progresses, :flagged, :boolean, default: false
  end
end
