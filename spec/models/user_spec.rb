require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = { 
      :name => "Example User", 
      :email => "user@example.com", 
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end
  
  it "should create a new instace given valid attributes" do
    User.create!(@attr)
  end
  
  describe "name validation" do
    it "should require a name" do
      no_name_user = User.new(@attr.merge(:name => ""))
      no_name_user.should_not be_valid
    end
  
    it "should reject names that are too long" do
      long_name = "a" * 51
      long_name_user = User.new(@attr.merge(:name => long_name))
      long_name_user.should_not be_valid
    end
  end
  
  describe "email validation" do
    it "should require an email address" do
      no_email_user = User.new(@attr.merge(:email => ""))
      no_email_user.should_not be_valid
    end
  
    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should be_valid
      end
    end
    
    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
    end
  
    it "should reject duplicate email addresses" do
      User.create(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
  
    it "should reject duplicate email addresses insensitive to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
  end
  
  describe "password validation" do
     
    it "should require a password" do
      User.new(@attr.merge(
        :password => "", 
        :password_confirmation => "")).should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(
        :password_confirmation => "invalid")).should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      User.new(@attr.merge(
        :password => short, 
        :password_confirmation => short)).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      User.new(@attr.merge(
        :password => long, 
        :password_confirmation => long)).should_not be_valid
    end
  end
  
  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?('invalid').should be_false
      end
      
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], 'wrongpass')
        wrong_password_user.should be_nil
      end
      
      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate('bar@foo.com', @attr[:password])
        nonexistent_user.should be_nil
      end
      
      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  
  end

  describe "admin attribute" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
    
  end

  describe "match associations" do
  
    before(:each) do
      @user = User.create(@attr)
      @match1 = FactoryGirl.create(:match, defender: @user, created_at: 1.day.ago)
      @match2 = FactoryGirl.create(:match, defender: @user, created_at: 2.hour.ago)
      @match3 = FactoryGirl.create(:match, challenger: @user, created_at: 1.hour.ago)
    end
  
    it "should have a defender_matches attribute" do
      @user.should respond_to(:defender_matches)
    end
    
    it "should have a challenger_matches attribute" do
      @user.should respond_to(:challenger_matches)
    end
    
    it "should have a matches attribute" do
      @user.should respond_to(:matches)
    end
    
    it "should have the right defender matches in the right order" do
      @user.defender_matches.should == [@match2, @match1]
    end
    
    it "should have the right matches in the right order" do
      @user.matches.should == [@match3, @match2, @match1]
    end 
    
    it "should destroy associated matches" do
      @user.destroy
      [@match1, @match2].each do |match|
        Match.find_by_id(match.id).should be_nil
      end
    
    end
    
    describe "recent games" do

      it "should have recent games" do
        @user.should respond_to(:matches)
      end
      
      it "should include the user's games" do
        @user.matches.include?(@match1).should be_true
      end
      
      it "should not include the other users' games" do
        @match4 = FactoryGirl.create(:match, challenger: FactoryGirl.create(:user))
        @user.matches.include?(@match4).should be_false
      end

    end
    
  end

  describe "power rankings" do
    it "should have power_ranking attribute" do
      @user = User.create!(@attr)
      @user.should respond_to(:power_ranking  )
    end

    describe "setup" do
      it "players with no score should get a power ranking of 100" do
        @users = []
        10.times { @users.push FactoryGirl.create(:user, power_ranking: nil) }
        User.re_rank
        @users.each do |user|
          User.find(user).power_ranking.should == 100
        end
      end

      it "players with a score should not change their power ranking" do
        @default_ranking = 100
        @users = []
        10.times do
          @users.push FactoryGirl.create(:user, power_ranking: @default_ranking)
        end
        User.re_rank
        @users.each do |user|
          User.find(user).power_ranking.should == @default_ranking
        end
      end
    end

    describe "error calculation" do
      it "should calculate error correctly for one match" do
        @p1 = rand(100)
        @p2 = rand(100)
        @score1, @score2= Match.generate_valid_score
        @user_one = FactoryGirl.create(:user, power_ranking: @p1)
        @user_two = FactoryGirl.create(:user, power_ranking: @p2)
        @match = Match.create(defender: @user_one, challenger: @user_two,
                              defender_score: @score1, challenger_score: @score2)
        @user_one.error_for_match(@match).should == (@p1 - @p2) - (@score1 - @score2)
        @user_two.error_for_match(@match).should == (@p2 - @p1) - (@score2 - @score1)
      end

      it "should calculate error correctly for one challenger" do
        @user = FactoryGirl.create(:user, power_ranking: rand(100))
        @matches = []
        1.times do
          @matches.push FactoryGirl.create(:match, challenger: @user, defender: FactoryGirl.create(:user, power_ranking: rand(100)))
        end
        error = 0
        @matches.each do |match|
          error += (@user.power_ranking - match.defender.power_ranking) - (match.challenger_score - match.defender_score)
        end
        @user.error.should == error
        end

      it "should calculate error correctly for one defender" do
        @user = FactoryGirl.create(:user, power_ranking: rand(100))
        @matches = []
        1.times do
          @matches.push FactoryGirl.create(:match, defender: @user, challenger: FactoryGirl.create(:user, power_ranking: rand(100)))
        end
        error = 0
        @matches.each do |match|
          error += (@user.power_ranking - match.challenger.power_ranking) - (match.defender_score - match.challenger_score)
        end
        @user.error.should == error
      end
    end

    describe "update power_ranking" do
      it "should calculate the correct power ranking for a given error" do
        @pr = rand 100
        @error = 50 - rand(100)
        @user = FactoryGirl.build(:user, power_ranking: @pr)
        @user.update_power_ranking(@error).should == @pr + (@error * 0.4)
      end

      it "should have total error of 0 after reranking everyone" do
        @user = FactoryGirl.create(:user, power_ranking: rand(100))
        @user2 = FactoryGirl.create(:user, power_ranking: rand(100))
        c_score, d_score = Match.generate_valid_score
        FactoryGirl.create(:match, challenger_id: @user, defender_id: @user2,
                           challenger_score: c_score, defender_score: d_score)
        User.re_rank
        @user.error.should == 0
        @user2.error.should == 0
      end

      it "should choose power rankings that predict the score" do
        @user = FactoryGirl.create(:user)
        @user2 = FactoryGirl.create(:user, power_ranking: 100)
        FactoryGirl.create(:match, challenger_id: @user, defender_id: @user2,
                           challenger_score: 21, defender_score: 18)
        FactoryGirl.create(:match, challenger_id: @user, defender_id: @user2,
                           challenger_score: 21, defender_score: 17)
        FactoryGirl.create(:match, challenger_id: @user, defender_id: @user2,
                           challenger_score: 23, defender_score: 21)
        @user.error.should == -9
        @user2.error.should == 9
        User.re_rank
        #@user.power_ranking.should == 104.5
        #@user2.power_ranking.should == 95.5
      end
    end
  end
end