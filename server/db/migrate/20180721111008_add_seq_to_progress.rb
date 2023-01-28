class AddSeqToProgress < ActiveRecord::Migration[5.2]
  def change
    add_column :progresses, :seq, :integer
    add_index :progresses, :seq
  end
end
