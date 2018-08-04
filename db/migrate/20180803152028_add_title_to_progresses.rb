class AddTitleToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :title, :string
  end
end
