class CreateNewCardsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :element_type
      t.integer :level
      t.string :title
      t.json :details
      t.boolean :unlocked, default: false
      t.boolean :learned, default: false
      t.integer :deck
      t.date :scheduled
    end
    create_table :actions do |t|
      t.belongs_to :card, index: true
      t.integer :action_type, default: 0 # 1 unlock; 2 learn; 3 correct answer; 4 incorrect answer
      t.timestamps null: false
    end
  end
end
