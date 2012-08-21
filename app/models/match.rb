class Match < ActiveRecord::Base
  attr_accessible :defender_score, :challenger_score, 
                  :defender_id, :challenger_id,
                  # TODO Make these write-once only
                  :defender, :challenger
  belongs_to :defender, class_name: 'User', foreign_key: 'defender_id'
  belongs_to :challenger, class_name: 'User', foreign_key: 'challenger_id'
  
  validates :challenger_id,     presence: true
  validates :defender_id,       presence: true
  validates :challenger_score,  presence: true
  validates :defender_score,    presence: true
  validate  :reached_minimum_score

  default_scope order: 'matches.created_at DESC'
  after_save :re_rank

  def re_rank
    User.re_rank
  end

  def reached_minimum_score
    def add_error
      errors.add(:base, "Invalid Score: {#{challenger_score} : #{defender_score}}")
    end
    if challenger_score.nil? or defender_score.nil?
        add_error; return
    end
    add_error if challenger_score.equal?(defender_score)
    add_error if challenger_score < 21 and defender_score < 21
    add_error unless challenger_score >= defender_score + 2 or defender_score >= challenger_score + 2
  end

  def self.generate_valid_score
  w_score = 21 + rand(21)
  if w_score.equal?(21)
    l_score = 1 + rand(19)
  else
    l_score = 20 + rand(w_score - 21)
  end

  # assign scores randomly
  if rand(2) == 1
    c_score = w_score
    d_score = l_score
  else
    c_score = l_score
    d_score = w_score
  end
  return c_score, d_score
end
end
