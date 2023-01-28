class AddSosoAnswerSupportToLeitner < ActiveRecord::Migration[6.0]
  def change
    add_column :srs_progresses, :leitner_combo, :integer, default: 0
  end
end
