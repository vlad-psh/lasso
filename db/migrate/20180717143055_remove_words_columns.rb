class RemoveWordsColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :words, :en, :jsonb
    remove_column :words, :ru, :jsonb
    remove_column :words, :pos, :jsonb # remove permanently
    remove_column :words, :keb, :jsonb
    remove_column :words, :reb, :jsonb

    # Remove JSONB-type columns; add JSON type
    add_column :words, :en, :json
    add_column :words, :ru, :json
    add_column :words, :kele, :json
    add_column :words, :rele, :json
  end
end
