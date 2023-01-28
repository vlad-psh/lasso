class AddIndexesToJmTables < ActiveRecord::Migration[5.2]
  def change
    add_index :jm_elements, :ent_seq
    add_index :jm_elements, :title
    add_index :jm_meanings, :ent_seq
  end
end
