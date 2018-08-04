class AddWordDetailsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :word_details do |t|
      t.integer :seq
      t.integer :user_id
      t.string :comment
    end
  end
end
