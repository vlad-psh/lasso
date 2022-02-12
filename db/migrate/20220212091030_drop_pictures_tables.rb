class DropPicturesTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :picture_areas
    drop_table :pictures
  end
end
