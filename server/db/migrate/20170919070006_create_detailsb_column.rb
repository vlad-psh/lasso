class CreateDetailsbColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :detailsb, :jsonb
  end
end
