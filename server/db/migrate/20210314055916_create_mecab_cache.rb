class CreateMecabCache < ActiveRecord::Migration[6.1]
  def change
    create_table :mecab_cache do |t|
      t.string :key
      t.json :data
    end
  end
end
