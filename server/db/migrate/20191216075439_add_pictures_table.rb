class AddPicturesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :pictures do |t|
      t.string :filename
      t.string :sid
      t.string :tool
      t.string :source
      t.belongs_to :user
      t.timestamps
    end

    create_table :picture_areas do |t|
      t.belongs_to :picture
#      t.belongs_to :kanji
      t.string :symbol # this way we can use it not only for kanji, but also for kana
    end
  end
end
