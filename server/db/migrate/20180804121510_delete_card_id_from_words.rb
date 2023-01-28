class DeleteCardIdFromWords < ActiveRecord::Migration[5.2]
  def change
    remove_column :words, :card_id, :integer
  end
end
