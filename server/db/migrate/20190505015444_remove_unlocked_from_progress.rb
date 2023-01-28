class RemoveUnlockedFromProgress < ActiveRecord::Migration[5.2]
  def change
    remove_column :progresses, :unlocked, :boolean, default: false
    remove_column :progresses, :unlocked_at, :datetime
  end
end
