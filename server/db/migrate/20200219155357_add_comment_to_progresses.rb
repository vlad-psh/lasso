class AddCommentToProgresses < ActiveRecord::Migration[6.0]
  def change
    add_column :progresses, :comment, :text
  end
end
