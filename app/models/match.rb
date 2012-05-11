class Match < ActiveRecord::Base
  attr_accessible :defender_score, :challenger_score, 
                  :defender_id, :challenger_id,
                  # Make these write-once onely
                  :defender, :challenger
  belongs_to :defender, class_name: 'User', foreign_key: 'defender_id'
  belongs_to :challenger, class_name: 'User', foreign_key: 'challenger_id'
  
  validates :challenger_id,     presence: true
  validates :defender_id,       presence: true
  validates :challenger_score,  presence: true
  validates :defender_score,    presence: true
  
  default_scope order: 'matches.created_at DESC'
end
