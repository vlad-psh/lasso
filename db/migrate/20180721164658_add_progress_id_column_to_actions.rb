class AddProgressIdColumnToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :progress_id, :integer
  end
end
