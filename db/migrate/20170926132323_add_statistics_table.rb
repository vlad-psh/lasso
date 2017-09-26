class AddStatisticsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :statistics do |t|
      t.date :date
      t.jsonb :learned,   default: {r: 0, k: 0, w: 0}
      t.jsonb :scheduled, default: {r: 0, k: 0, w: 0}
    end
  end
end
