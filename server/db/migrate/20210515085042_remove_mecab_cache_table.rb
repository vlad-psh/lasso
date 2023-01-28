class RemoveMecabCacheTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :mecab_cache
  end
end
