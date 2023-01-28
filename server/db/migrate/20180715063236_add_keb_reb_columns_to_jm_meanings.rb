class AddKebRebColumnsToJmMeanings < ActiveRecord::Migration[5.2]
  def change
    add_column :jm_meanings, :keb, :jsonb
    add_column :jm_meanings, :reb, :jsonb
  end
end
