class AddFailsToUsercards < ActiveRecord::Migration[5.2]
  def change
    add_column :user_cards, :failed, :boolean, default: false
  end
end
