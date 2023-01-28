class AddDrillSetsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :drills do |t|
      t.string :title
      t.belongs_to :user
      t.datetime :created_at
    end

    create_table :drills_progresses do |t|
      t.belongs_to :drill
      t.belongs_to :progress
      t.datetime :created_at
    end
  end
end
