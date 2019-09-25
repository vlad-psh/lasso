class AddReviewedAtToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :reviewed_at, :datetime
  end
end
