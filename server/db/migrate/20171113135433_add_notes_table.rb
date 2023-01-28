class AddNotesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :content
      t.timestamps null: false
    end
  end
end
