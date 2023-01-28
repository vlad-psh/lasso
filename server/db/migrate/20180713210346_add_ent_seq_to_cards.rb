class AddEntSeqToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :ent_seq, :integer
  end
end
