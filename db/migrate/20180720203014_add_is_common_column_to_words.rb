class AddIsCommonColumnToWords < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :is_common, :boolean
  end
end
