class RemoveKindFromSrsProgresses < ActiveRecord::Migration[6.0]
  def change
    remove_column :srs_progresses, :kind, :integer
  end
end
