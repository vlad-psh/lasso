class AddActivityTable < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|
      t.belongs_to :user
      t.date :date
      t.integer :category
      t.bigint :seconds, default: 0
    end
  end
end
