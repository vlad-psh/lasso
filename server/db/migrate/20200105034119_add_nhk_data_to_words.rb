class AddNhkDataToWords < ActiveRecord::Migration[6.0]
  def change
    add_column :words, :nhk_data, :jsonb
  end
end
