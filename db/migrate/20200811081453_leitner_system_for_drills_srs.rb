class LeitnerSystemForDrillsSrs < ActiveRecord::Migration[6.0]
  def change
    add_column :srs_progresses, :leitner_box, :integer
    add_column :srs_progresses, :leitner_last_reviewed_at_session, :integer
    add_column :users, :leitner_session, :integer, default: 0
    add_column :users, :leitner_fresh, :integer, default: 0
  end
end
