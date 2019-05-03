class AddWkInternalIdColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :wk_radicals, :wk_internal_id, :integer
    add_column :wk_kanji,    :wk_internal_id, :integer
    add_column :wk_words,    :wk_internal_id, :integer
  end
end
