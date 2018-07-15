class RenameUserCardsToProgress < ActiveRecord::Migration[5.2]
  def change
    rename_table :user_cards, :progresses
  end
end
