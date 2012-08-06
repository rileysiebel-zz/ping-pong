class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name, :password, :password_confirmation, :power_ranking
  
  has_many :defender_matches,   class_name: 'Match', foreign_key: :defender_id,   dependent: :destroy
  has_many :challenger_matches, class_name: 'Match', foreign_key: :challenger_id, dependent: :destroy
  
  # Validation
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,  :presence   => true,
                    :length     => { :maximum => 50 }
  validates :email, :presence   => true,
                    :uniqueness => { :case_sensitive => false },
                    :format     => { :with => email_regex }
  validates :password,  :presence     => true,
                        :confirmation => true,
                        :length       => { :within => 6...40 }
                        
  before_save :encrypt_password
  public
    def matches
      #@matches = defender_matches + challenger_matches
      # show most recent first
      #@matches.sort {|x, y| y.created_at <=> x.created_at } 
    
      Match.where("defender_id == ? OR challenger_id == ?", id, id)
    end
    
    def has_password?(submitted_password)
      encrypted_password == encrypt(submitted_password)
    end
  
    def self.authenticate(email, submitted_password)
      user = find_by_email email
      return nil if user.nil?
      return user if user.has_password? submitted_password
    end
  
    def self.authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end
    
    def self.random
      if (c = count) != 0
        find(:first, offset: rand(c))
      end
    end

    def self.re_rank
      # Give newcomers a new rank
      User.all.each { |user| user.update_attribute(:power_ranking, 50) if user.power_ranking.nil? }
      #error = 1
      #until error == 0
      #  error = 0
      #  new_score = {}
      #  User.all.each do |user|
      #    u_error = user.error
      #    new_score[user] = user.update_power_ranking u_error
      #    error += u_error
      #  end
      #  User.all.each do |user|
      #    user.update_attribute :power_ranking, new_score[user]
      #  end
      #end
    end

    def update_power_ranking(error)
      return self.power_ranking + (error * 0.8)
    end

    def error
      self.matches.inject(0) {|error, match| error + error_for_match(match)}
    end

    def error_for_match(match)
      if (self == match.defender)
        p1 = match.defender.power_ranking
        p2 = match.challenger.power_ranking
        s1 = match.defender_score
        s2 = match.challenger_score
      else
        p1 = match.challenger.power_ranking
        p2 = match.defender.power_ranking
        s1 = match.challenger_score
        s2 = match.defender_score
      end

      return (p1 - p2) - (s1 - s2)
    end
  
  private
    def encrypt_password
      self.encrypted_password = encrypt(password)
    end
    
    def encrypt(string)
      string #TODO finish implementing
    end
end
