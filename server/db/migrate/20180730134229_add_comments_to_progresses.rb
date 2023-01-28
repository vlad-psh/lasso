class AddCommentsToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :comments, :string
  end
end
