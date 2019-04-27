class DeleteFailedColumnFromProgresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :progresses, :failed, :boolean, default: false
  end
end
