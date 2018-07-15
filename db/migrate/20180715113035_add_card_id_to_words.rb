class AddCardIdToWords < ActiveRecord::Migration[5.2]
  def change
    add_column :words, :card_id, :integer
  end
end
