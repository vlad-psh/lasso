class AddFlaggedAtToProgress < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :flagged_at, :datetime
  end
end
