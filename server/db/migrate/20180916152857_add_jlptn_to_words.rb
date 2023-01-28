class AddJlptnToWords < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :jlptn, :integer
  end
end
