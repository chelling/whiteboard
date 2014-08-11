class HomeController < ApplicationController
  def index
    @header_title = "Welcome"
    @mobile_header = "FOO-NATION"
    @year = Date.today.year
  end

  def user_wagers
    @year = Time.now.year
    @year = params[:year] if params[:year]
    @user_id = params[:user_id]

    if !@user_id.nil? and !@year.nil?
      @user = User.find(@user_id)
      @amount = @user.find_balance_by_year(@year)
      @wagers = @user.find_wager_picks_by_year(@year)
    end
  end
end
