require 'spec_helper'

describe Match do

  describe "create users and matches" do
    before(:each) do
      @user_one = FactoryGirl.create(:user)
      @user_two = FactoryGirl.create(:user)
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

      it "should require a challenger id" do
        Match.new(@attr.merge(defender: @user_one)).should_not be_valid
      end

      it "should require a defender id" do
        Match.new(@attr.merge(challenger: @user_one)).should_not be_valid
      end

      it "should require a challenger score" do
        @my_attr = {defender_score: 21, defender: @user_one, challenger: @user_two}
        Match.new(@my_attr).should_not be_valid
      end

      it "should require a defender score" do
        @my_attr = {challenger_score: 21, defender: @user_one, challenger: @user_two}
        Match.new(@my_attr).should_not be_valid
      end

      it "should accept valid matches" do
        @my_attr = {defender: @user_one, challenger: @user_two, defender_score: 21, challenger_score: 15}
        Match.new(@attr.merge(@my_attr)).should be_valid
      end

      # PENDING (NEED TO KNOW MORE ABOUT VALIDATION)
      describe "score" do

        before(:each) do
          @attr = {challenger: @user_one, defender: @user_two}
        end

        describe "standard" do
          it "should require 1 score to be 21" do
            @my_attr = {defender_score: 20, challenger_score: 15}
            Match.new(@attr.merge(@my_attr)).should_not be_valid
          end

          it "should require only 1 score to be 21" do
            @my_attr = {defender_score: 21, challenger_score: 21}
            Match.new(@attr.merge(@my_attr)).should_not be_valid
          end
          it "should accept when defender score is 21" do
            @my_attr = {defender_score: 21, challenger_score: 15}
            Match.new(@attr.merge(@my_attr)).should be_valid
          end
          it "should accept when challenger score is 21" do
            @my_attr = {defender_score: 15, challenger_score: 21}
            Match.new(@attr.merge(@my_attr)).should be_valid
          end
        end

        describe "extra points" do

          it "should require the difference to be greater than 2" do
            @my_attr = {defender_score: 22, challenger_score: 21}
            Match.new(@attr.merge(@my_attr)).should_not be_valid
          end

          it "should accept when challenger wins by 2" do
            @my_attr = {defender_score: 20, challenger_score: 22}
            Match.new(@attr.merge(@my_attr)).should be_valid
          end

          it "should accept when defender wins by 2" do
            @my_attr = {defender_score: 22, challenger_score: 20}
            Match.new(@attr.merge(@my_attr)).should be_valid
          end
        end

        it "should create valid score examples" do
          25.times do
            c_score, d_score = Match.generate_valid_score
            @my_attr = {defender_score: d_score, challenger_score: c_score}
            if(!Match.new(@attr.merge(@my_attr)).valid?)
              print "c_score: #{c_score}, d_score: #{d_score}\n"
            end
            Match.new(@attr.merge(@my_attr)).should be_valid
          end
        end

      end

    end
  end
end
