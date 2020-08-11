class MoveLeitnerSessionNumberToDrills < ActiveRecord::Migration[6.0]
  def change
    add_column :drills, :leitner_session, :integer, default: 0
    add_column :drills, :leitner_fresh, :integer, default: 0
    remove_column :users, :leitner_session, :integer, default: 0
    remove_column :users, :leitner_fresh, :integer, default: 0
  end
end
