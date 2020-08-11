class RemoveOldDrillSrsFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :srs_progresses, :drill_deck, :integer
    remove_column :srs_progresses, :drill_order, :bigint
  end
end
