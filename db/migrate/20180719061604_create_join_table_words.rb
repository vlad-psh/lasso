class CreateJoinTableWords < ActiveRecord::Migration[5.2]
  def change
    create_table :word_connections, id: false do |t|
      t.integer :long_seq, null: false, index: true
      t.integer :short_seq, null: false, index: true
    end
  end
end
