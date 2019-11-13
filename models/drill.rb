class Drill < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :progresses
  has_many :sentences
end
