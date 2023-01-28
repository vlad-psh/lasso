class AddRussianWords < ActiveRecord::Migration[5.1]
  def change
    create_table :russian_words do |t|
      t.string :title
    end
  end
end
