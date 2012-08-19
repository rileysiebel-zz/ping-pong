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
    before(:each) do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @match1 = FactoryGirl.create(:match, challenger: @user1, defender: @user2,
                                   challenger_score: 21, defender_score: 18)
      @match2 = FactoryGirl.create(:match, challenger: @user1, defender: @user2,
                                   challenger_score: 21, defender_score: 17)
      @match3 = FactoryGirl.create(:match, challenger: @user1, defender: @user2,
                                   challenger_score: 23, defender_score: 21)
    end

    it "should have power_ranking attribute" do
      @user1.should respond_to(:power_ranking)
    end

    it "should start with a power ranking of 100" do
      @user1.power_ranking.should == 100
      @user2.power_ranking.should == 100
    end

    describe "error calculation" do

      it "should calculate error correctly for one match" do
        @user1.error_for_match(@match1).should == -3
        @user1.error_for_match(@match2).should == -4
        @user1.error_for_match(@match3).should == -2
        @user2.error_for_match(@match1).should == 3
        @user2.error_for_match(@match2).should == 4
        @user2.error_for_match(@match3).should == 2
      end

      it "should calculate error correctly" do
        @user1.error.should == -9
        @user2.error.should == 9
      end
    end

    describe "update power_ranking" do
      # pr - error / (#games * 2)
      it "should calculate the correct power ranking for a given error" do
        @user1.update_power_ranking(30)
        @user1.reload
        @user1.power_ranking.should == 95
      end

      it "should have total error of 0 after reranking everyone" do
        User.re_rank
        @user1.error.should == 0
        @user2.error.should == 0
      end

      it "should choose power rankings that predict the score" do
        User.re_rank
        @user1.reload.power_ranking.should == 101.5
        @user2.reload.power_ranking.should == 98.5
      end
    end
  end
end
