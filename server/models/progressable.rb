require 'active_support/concern'

module Progressable
  extend ActiveSupport::Concern

  included do
    def self.as_for(user)
      progresses = Progress.joins(model_name.singular.to_sym).merge(all).where(user: user)
      all.each do |i|
        association = i.association(:progresses)
        filtered_progresses = progresses.find_all{|p| p.send(association.reflection.foreign_key) == i.send(association.reflection.active_record_primary_key)}
        association.target.concat(filtered_progresses)
# don't know meaning of following )
#        filtered_progresses.each {|i| association.set_inverse_instance(i)}
        association.loaded!
      end
    end

 #   has_many :uprogs, ->{where(user_id: 1)}, class_name: 'Progress', primary_key: :seq, foreign_key: :seq
 #   scope :as_for, ->(user) {
 #     eager_load(:uprogs)
 #   }
  end

  def best_progress
# TODO: real best progress)
    self.association(:progresses).loaded? ? progresses.first : null
  end

end

