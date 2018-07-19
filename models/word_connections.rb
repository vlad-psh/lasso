class WordConnection < ActiveRecord::Base
  belongs_to :long_word, class_name: 'Word', primary_key: :seq, foreign_key: :long_seq
  belongs_to :short_word, class_name: 'Word', primary_key: :seq, foreign_key: :short_seq
end

