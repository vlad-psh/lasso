class AddIsActiveToDrills < ActiveRecord::Migration[5.2]
  def change
    add_column :drills, :is_active, :boolean, default: true
  end
end
