class CardsRelation < ActiveRecord::Base
  belongs_to :card
  belongs_to :relation, class_name: 'Card'
end

