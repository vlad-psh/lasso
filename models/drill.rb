class Drill < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :progresses
  has_many :sentences

  def reset_leitner(learning_type)
    SrsProgress.joins(:progress).merge(self.progresses) \
      .where(learning_type: learning_type, leitner_combo: 4) \
      .update_all(leitner_combo: 3)
  end
end
