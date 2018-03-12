class AddUserSpecificContentTable < ActiveRecord::Migration[5.1]
  def change
    create_table :user_cards do |t|
      t.belongs_to :card
      t.belongs_to :user
      t.boolean :unlocked, default: false
      t.boolean :learned, default: false
      t.integer :deck
      t.date :scheduled
      t.jsonb :details
    end
    add_column :statistics, :user_id, :integer
    add_column :actions,    :user_id, :integer
    add_column :notes,      :user_id, :integer
  end
end
