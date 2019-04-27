class AddTransitionToProgresses < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :transition, :date
  end
end
