class CreateRelationsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :cards_relations do |t|
      t.belongs_to :card
      t.integer :relation_id, null: false
    end
  end
end
