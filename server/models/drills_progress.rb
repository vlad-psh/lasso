class DrillsProgress < ActiveRecord::Base
  belongs_to :drill
  belongs_to :progress

  validates :progress, uniqueness: { scope: :drill }
end
