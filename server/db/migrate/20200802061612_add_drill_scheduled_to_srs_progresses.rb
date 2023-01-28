class AddDrillScheduledToSrsProgresses < ActiveRecord::Migration[6.0]
  def change
    add_column :srs_progresses, :drill_deck, :integer
    add_column :srs_progresses, :drill_order, :bigint
  end
end
