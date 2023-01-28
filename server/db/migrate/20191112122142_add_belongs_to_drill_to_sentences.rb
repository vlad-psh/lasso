class AddBelongsToDrillToSentences < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :sentences, :drill
    add_belongs_to :sentences, :user
  end
end
