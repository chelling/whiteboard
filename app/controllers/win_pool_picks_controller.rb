class WinPoolPicksController < ApplicationController
  respond_to :html

  before_action :require_login
  before_action :load_win_pool_pick, except: [:index, :new, :create, :win_pool, :pick_team]
  before_action :load_win_pool_league, only: [:win_pool, :pick_team]

  # GET /win_pool_picks
  # GET /win_pool_picks.json
  def index
    @win_pool_picks = WinPoolPick.all
    authorize! :manage, @win_pool_picks
  end

  # GET /win_pool_picks/1
  # GET /win_pool_picks/1.json
  def show
    authorize! :manage, @win_pool_pick
  end

  # GET /win_pool_picks/new
  # GET /win_pool_picks/new.json
  def new
    @win_pool_pick = WinPoolPick.new
    authorize! :create, @win_pool_pick
  end

  # GET /win_pool_picks/1/edit
  def edit
    authorize! :update, @win_pool_pick
  end

  # POST /win_pool_picks
  # POST /win_pool_picks.json
  def create
    @win_pool_pick = WinPoolPick.new
    authorize! :create, @win_pool_pick
    @win_pool_pick.update win_pool_pick_params

    respond_with @win_pool_pick
  end

  # PUT /win_pool_picks/1
  # PUT /win_pool_picks/1.json
  def update
    authorize! :update, @win_pool_pick

    @win_pool_pick.update win_pool_pick_params
    respond_with @win_pool_pick
  end

  # DELETE /win_pool_picks/1
  # DELETE /win_pool_picks/1.json
  def destroy
    authorize! :destroy, @win_pool_pick
    @win_pool_pick.destroy

    respond_with @win_pool_pick
  end

  def win_pool
    @mobile_header = "Win Pool"

    @year = @league.year
    @teams = @league.teams_remaining
    if !@win_pool_pick.nil?
      authorize! :update, @win_pool_pick
      @current_pick = @league.get_current_pick
      @is_my_pick = @win_pool_pick.is_current_user_turn?
    end
  end

  def pick_team
    if !@win_pool_pick.nil?
      authorize! :update, @win_pool_pick
      team = Team.find(params[:teams])
      @is_my_pick = @win_pool_pick.is_current_user_turn?

      if @is_my_pick
        if @win_pool_pick.team_one.nil?
          @win_pool_pick.team_one = team
        elsif @win_pool_pick.team_two.nil?
          @win_pool_pick.team_two = team
        elsif @win_pool_pick.team_three.nil?
          @win_pool_pick.team_three = team
        end

        @win_pool_pick.save
      end

      # Email current user
      UserMailer.win_pool_pick.deliver
      UserMailer.pick_submitted.deliver
    end

    redirect_to "/winpool/#{params[:id]}"
  end

private

  def load_win_pool_league
    @league = WinPoolLeague.where(id: params[:id]).includes(win_pool_picks: [team_one: :records, team_two: :records, team_three: :records]).first
    @win_pool_pick = WinPoolPick.where(user_id: current_user.id, year: @league.year, win_pool_league_id: params[:id]).includes(team_one: :records, team_two: :records, team_three: :records).first
  end

  def load_win_pool_pick
    @win_pool_pick = WinPoolPick.find(params[:id])
  end

  def win_pool_pick_params
    params.require(:win_pool_pick).permit :starting_position, :team_one_id, :team_three_id, :team_two_id, :user_id, :win_pool_league_id, :year
  end
end
