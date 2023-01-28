class AddBurnedAtToProgress < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :burned_at, :datetime
  end
end
