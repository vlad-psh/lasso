class Drill < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :progresses
  has_many :drills_progresses
  has_many :sentences

  validates :title, presence: true

  def reset_leitner(learning_type)
    SrsProgress.joins(:progress).merge(self.progresses) \
      .where(learning_type: learning_type, leitner_combo: 4) \
      .update_all(leitner_combo: 3)

    srs_progresses = SrsProgress.joins(:progress).merge(self.progresses) \
      .where(learning_type: learning_type).where.not(leitner_box: nil).pluck(:id).shuffle
    (0..9).each do |box|
      ids = srs_progresses.select.each_with_index {|_, i| i % 10 == box}
      SrsProgress.where(id: ids).update_all(leitner_box: box)
    end
  end

  def to_h
    self.serializable_hash(only: [:id, :title, :is_active, :updated_at])
  end
end
