class User < ActiveRecord::Base
  attr_accessible :email, :name
  
  
  # Validation
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,  :presence   => true,
                    :length     => { :maximum => 50 }
  validates :email, :presence   => true,
                    :uniqueness => { :case_sensitive => false },
                    :format     => { :with => email_regex }
end
