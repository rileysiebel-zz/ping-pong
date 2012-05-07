class Match < ActiveRecord::Base
  attr_accessible :user_one_score, :user_two_score, 
                  :user_one_id, :user_two_id
  belongs_to :home_player, class_name: 'User', foreign_key: 'user_one_id'
  belongs_to :away_player, class_name: 'User', foreign_key: 'user_two_id'
  
  def matches.create()
  
end
