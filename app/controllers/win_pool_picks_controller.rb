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

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @win_pool_picks }
    end
  end

  # GET /win_pool_picks/1
  # GET /win_pool_picks/1.json
  def show
    authorize! :manage, @win_pool_pick

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @win_pool_pick }
    end
  end

  # GET /win_pool_picks/new
  # GET /win_pool_picks/new.json
  def new
    @win_pool_pick = WinPoolPick.new
    authorize! :create, @win_pool_pick

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @win_pool_pick }
    end
  end

  # GET /win_pool_picks/1/edit
  def edit
    authorize! :update, @win_pool_pick
  end

  # POST /win_pool_picks
  # POST /win_pool_picks.json
  def create
    @win_pool_pick = WinPoolPick.new(params[:win_pool_pick])
    authorize! :create, @win_pool_pick

    respond_to do |format|
      if @win_pool_pick.save
        format.html { redirect_to @win_pool_pick, notice: 'Win pool pick was successfully created.' }
        format.json { render json: @win_pool_pick, status: :created, location: @win_pool_pick }
      else
        format.html { render action: "new" }
        format.json { render json: @win_pool_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /win_pool_picks/1
  # PUT /win_pool_picks/1.json
  def update
    authorize! :update, @win_pool_pick

    respond_to do |format|
      if @win_pool_pick.update_attributes(params[:win_pool_pick])
        format.html { redirect_to @win_pool_pick, notice: 'Win pool pick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @win_pool_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /win_pool_picks/1
  # DELETE /win_pool_picks/1.json
  def destroy
    authorize! :destroy, @win_pool_pick
    @win_pool_pick.destroy

    respond_to do |format|
      format.html { redirect_to win_pool_picks_url }
      format.json { head :no_content }
    end
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
    @league = WinPoolLeague.find(params[:id])
    @win_pool_pick = WinPoolPick.where(user_id: current_user.id, year: @league.year, win_pool_league_id: params[:id]).first
  end

  def load_win_pool_pick
    @win_pool_pick = WinPoolPick.find(params[:id])
  end

  def win_pool_pick_params
    params.require(:win_pool_pick).permit :starting_position, :team_one_id, :team_three_id, :team_two_id, :user_id, :win_pool_league_id, :year
  end
end
