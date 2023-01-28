class AddErrorsToSrsProgresses < ActiveRecord::Migration[6.0]
  def change
    add_column :srs_progresses, :fail_count, :integer, default: 0
  end
end
