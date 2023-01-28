class AddUpdatedAtToDrills < ActiveRecord::Migration[7.0]
  def change
    add_column :drills, :updated_at, :datetime
  end
end
