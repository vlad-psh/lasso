class DropWordConnectionsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :word_connections
  end
end
