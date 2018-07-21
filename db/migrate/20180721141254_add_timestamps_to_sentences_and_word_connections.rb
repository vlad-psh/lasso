class AddTimestampsToSentencesAndWordConnections < ActiveRecord::Migration[5.2]
  def change
    add_column :sentences, :created_at, :datetime
    add_column :word_connections, :created_at, :datetime
  end
end
