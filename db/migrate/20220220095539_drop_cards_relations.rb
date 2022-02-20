class DropCardsRelations < ActiveRecord::Migration[7.0]
  def change
    drop_table :cards_relations
  end
end
