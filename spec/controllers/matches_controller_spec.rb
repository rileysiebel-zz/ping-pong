require 'spec_helper'

describe MatchesController do
  render_views
  
  describe "access control" do
  
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end
  
    it "should deny access to 'destroy'" do
      delete :destroy, id: 1
      response.should redirect_to(signin_path)
    end
  
  end
  
  describe "POST 'create'" do
  
    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:user))
      @attr = {defender_score: 10, challenger_score: 15} 
    end
    
    describe "failure" do
      
      it "should not create a match" do
        lambda do
          post :create, match: @attr 
        end.should_not change(Match, :count)
      end
      
      it "should render the home page" do
        post :create, match: @attr
        response.should render_template('pages/home')
      end
      
    end
  
    describe "success" do
    
      before(:each) do
        @user_2 = FactoryGirl.create(:user)
        @attr = @attr.merge({ challenger: @user_2 })
      end
      
      it "should create a match" do
        lambda do
          post :create, match: @attr
        end.should change(Match, :count).by(1) 
      end
      
      it "should redirect to the home page" do
        post :create, match: @attr
        response.should redirect_to(root_path)
      end
      
      it "should have a flash message" do
        post :create, match: @attr
        flash[:success].should =~ /match created/i
      end
    
    end
  
  end
  
end