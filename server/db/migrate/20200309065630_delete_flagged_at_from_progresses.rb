class DeleteFlaggedAtFromProgresses < ActiveRecord::Migration[6.0]
  def change
    remove_column :progresses, :flagged_at, :datetime
  end
end
