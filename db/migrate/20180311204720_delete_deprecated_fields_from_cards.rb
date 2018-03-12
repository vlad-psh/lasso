class DeleteDeprecatedFieldsFromCards < ActiveRecord::Migration[5.1]
  def change
    remove_column :cards, :unlocked
    remove_column :cards, :learned
    remove_column :cards, :deck
    remove_column :cards, :scheduled
  end
end
