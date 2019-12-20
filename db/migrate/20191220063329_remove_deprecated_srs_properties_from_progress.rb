class RemoveDeprecatedSrsPropertiesFromProgress < ActiveRecord::Migration[6.0]
  def change
    remove_column :progresses, :_deck, :integer
    remove_column :progresses, :_scheduled, :date
    remove_column :progresses, :_transition, :date
    remove_column :progresses, :_reviewed_at, :datetime
  end
end
