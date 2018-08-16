class RemoveKeleAndReleFromWords < ActiveRecord::Migration[5.2]
  def change
    remove_column :words, :kele, :jsonb
    remove_column :words, :rele, :jsonb
  end
end
