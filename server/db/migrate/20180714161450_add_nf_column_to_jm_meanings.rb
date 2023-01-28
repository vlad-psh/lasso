class AddNfColumnToJmMeanings < ActiveRecord::Migration[5.2]
  def change
    add_column :jm_meanings, :nf, :integer
  end
end
