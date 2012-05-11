require 'spec_helper'

describe Match do
  
  before(:each) do
    @user_one = FactoryGirl.create(:user)
    @user_two = FactoryGirl.create(:user, email: "another@example.com")
    @attr = { challenger_score: 17, defender_score: 21 }
  end
  
  it "should create a new instance as a defender given valid attributes" do
    @user_one.defender_matches.create!(@attr.merge({ challenger: @user_two }))
  end
  
  it "should create a new instance as a challenger given valid attributes" do
    @user_one.challenger_matches.create!(@attr.merge({ defender: @user_two }))
  end
  
  describe "user associations" do
  
    describe "created from defender" do
      before(:each) do
        @match = @user_one.defender_matches.create(@attr.merge({ challenger: @user_two }))
      end
    
      it "should have a player_one attribute" do
        @match.should respond_to(:challenger)
      end
    
      it "should have a player_two attribute" do
        @match.should respond_to(:defender)
      end
    
      it "should have the correct associated player_one" do
        @match.defender_id.should == @user_one.id
        @match.defender.should == @user_one
      end
    
      it "should have the correct associated player_two" do
        @match.challenger_id.should == @user_two.id
        @match.challenger.should == @user_two
      end
    end
    
    describe "created from challenger" do
      before(:each) do
        @match = @user_one.challenger_matches.create(@attr.merge({ defender: @user_two}))
      end
    
      it "should have a player_one attribute" do
        @match.should respond_to(:challenger)
      end
    
      it "should have a player_two attribute" do
        @match.should respond_to(:defender)
      end
    
      it "should have the correct associated defender" do
        @match.defender_id.should == @user_two.id
        @match.defender.should == @user_two
      end
    
      it "should have the correct associated challenger" do
        @match.challenger_id.should == @user_one.id
        @match.challenger.should == @user_one
      end
    end
  
  end
 
  describe "validation" do
  
    it "should require a challenger id" 
        
    it "should require a defender id" 
       
    it "should require a challenger score" 
    
    it "should require a defender score" 
  
    describe "score" do
    
      it "should require one score of 21 or greater"
      
      describe "greater than 21" do
        
        it "should have scores with difference exactly 2"
        
      end
    
    end
  
  end
  
end
