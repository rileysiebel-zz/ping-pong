class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name, :password, :password_confirmation
  
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
      @matches = defender_matches + challenger_matches
      # show most recent first
      @matches.sort {|x, y| y.created_at <=> x.created_at } 
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
  
  private
    def encrypt_password
      self.encrypted_password = encrypt(password)
    end
    
    def encrypt(string)
      string #TODO finish implementing
    end
end
