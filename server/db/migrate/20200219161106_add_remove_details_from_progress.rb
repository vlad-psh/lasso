class AddRemoveDetailsFromProgress < ActiveRecord::Migration[6.0]
  def change
    remove_column :progresses, :details, :jsonb
  end
end
