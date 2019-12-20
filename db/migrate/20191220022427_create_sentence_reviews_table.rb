class CreateSentenceReviewsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :sentence_reviews do |t|
      t.belongs_to :sentence
      t.belongs_to :user
      t.integer :learning_type, default: 0
      t.datetime :reviewed_at
    end
  end
end
