class CreateKebsRebsColumnsInWords < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :kebs, :jsonb
    add_column :words, :rebs, :jsonb
  end
end
