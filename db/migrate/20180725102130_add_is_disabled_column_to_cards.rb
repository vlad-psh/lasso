class AddIsDisabledColumnToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :is_disabled, :boolean, default: false
  end
end
