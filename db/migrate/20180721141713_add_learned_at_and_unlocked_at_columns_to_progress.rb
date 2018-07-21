class AddLearnedAtAndUnlockedAtColumnsToProgress < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :unlocked_at, :datetime
    add_column :progresses, :learned_at, :datetime
  end
end
