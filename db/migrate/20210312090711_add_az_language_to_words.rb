class AddAzLanguageToWords < ActiveRecord::Migration[6.1]
  def change
    add_column :words, :az, :json
  end
end
