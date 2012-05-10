class Match < ActiveRecord::Base
  attr_accessible :defender_score, :challenger_score, 
                  :defender_id, :challenger_id
  belongs_to :defender, class_name: 'User', foreign_key: 'user_one_id'
  belongs_to :challenger, class_name: 'User', foreign_key: 'user_two_id'
  
end
