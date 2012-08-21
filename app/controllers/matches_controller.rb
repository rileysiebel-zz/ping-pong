class MatchesController < ApplicationController
  before_filter :authenticate, only: [:create, :destroy]

  def re_rank
    User.re_rank
  end

  def create
    @match = current_user.defender_matches.build(params[:match])
    if @match.save
      flash[:success] = "Match created!"
      redirect_to root_path
    else
      @matches = []
      render "pages/home"
    end
  end
  
  def destroy
  end

end
