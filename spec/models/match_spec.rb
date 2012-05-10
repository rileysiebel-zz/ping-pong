require 'spec_helper'

describe Match do
  
  before(:each) do
    @user_one = FactoryGirl.create(:user)
    @user_two = FactoryGirl.create(:user, email: "another@example.com")
    @attr = { challenger_score: 17, defender_score: 21 }
  end
  
  it "should create a new instance given valid attributes" do
    @user_one.matches.create!(@attr)
  end
  
  describe "user associations" do
  
    before(:each) do
      @match = @user_one.matches.create(@attr)
    end
    
    it "should have a player_one attribute" do
      @match.should respond_to(:user_one)
    end
    
    it "should have a player_two attribute" do
      @match.should respond_to(:user_two)
    end
    
    it "should have the right associated player_one" do
      @match.user_one_id.should == @user_one.id
      @match.user_one.should == @user_one
    end
    
    it "should have the right associated player_two" do
      @match.user_two_id.should == @user_two.id
      @match.user_two.should == @user_two
    end
  
  end
  
end
