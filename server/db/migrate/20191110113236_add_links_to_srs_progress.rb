class AddLinksToSrsProgress < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :actions, :srs_progress
    add_column :srs_progresses, :kind, :integer
    remove_column :statistics, :scheduled, :date
    remove_column :progresses, :kind, :integer
  end
end
