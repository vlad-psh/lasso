class AddActivityTimeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :activity, :jsonb, default: {}
  end
end
