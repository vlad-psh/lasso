class RemoveLearnedColumnFromProgresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :progresses, :learned, :boolean, default: false
  end
end
