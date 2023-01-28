class RemoveCommentsColumnFromProgresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :progresses, :comments, :string
  end
end
