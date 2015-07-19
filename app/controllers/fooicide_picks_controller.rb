class FooicidePicksController < ApplicationController
  respond_to :html

  before_action :require_login
  before_action :load_fooicide_pick, except: [:index, :new, :create, :scores, :update_picks]

  # GET /fooicide_picks
  # GET /fooicide_picks.json
  def index
    @fooicide_picks = FooicidePick.all
    authorize! :manage, @fooicide_picks
  end

  # GET /fooicide_picks/1
  # GET /fooicide_picks/1.json
  def show
    authorize! :manage, @fooicide_pick
  end

  # GET /fooicide_picks/new
  # GET /fooicide_picks/new.json
  def new
    @fooicide_pick = FooicidePick.new
    authorize! :create, @fooicide_pick
  end

  # GET /fooicide_picks/1/edit
  def edit
    authorize! :update, @fooicide_pick
  end

  # POST /fooicide_picks
  # POST /fooicide_picks.json
  def create
    @fooicide_pick = FooicidePick.new
    authorize! :create, @fooicide_pick

    @fooicide_pick.update win_pool_pick_params
    respond_with @fooicide_pick
  end

  # PUT /fooicide_picks/1
  # PUT /fooicide_picks/1.json
  def update
    authorize! :update, @fooicide_pick

    @fooicide_pick.update win_pool_pick_params
    respond_with @fooicide_pick
  end

  # DELETE /fooicide_picks/1
  # DELETE /fooicide_picks/1.json
  def destroy
    authorize! :destroy, @fooicide_pick
    @fooicide_pick.destroy

    respond_with @fooicide_pick
  end

  def scores
    @mobile_header = "Fooicide"
    @year = Time.now.year
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]
    @games = Game.where(year: @year, week: @week).order("date ASC")
    @pickem_picks = current_user.pickem_picks.where(year: @year, week: @week)
    @users = User.order_all_by_fooicide_record(@year)
    # get bye teams
    team_ids = []
    @games.try(:map) do |game|
      team_ids << game.away_team_id unless team_ids.include?(game.away_team_id)
      team_ids << game.home_team_id unless team_ids.include?(game.home_team_id)
    end
    (Team.all.map(&:id) - team_ids).try(:map) do |team_id|
      team = Team.find_by(id: team_id)
      if @bye_teams.nil?
        @bye_teams = "#{team.location}"
      else
        @bye_teams += ", #{team.location}"
      end
    end
  end
  
  def rules
  end

  # add picks to user table
  def update_picks
    @year = Time.now.year
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]

    # go through each "week_#"
    params.each do |key,value|
      week = key.split('_')

      if week.first == "week"
        pick = FooicidePick.where(year: @year, week: week.last, user_id: current_user.id).first
        if !pick.nil?
          authorize! :update, pick
        else
          pick = FooicidePick.new
          authorize! :create, pick
        end

        # find game id for this team
        game_id = Game.where(year: @year, week: week.last, away_team_id: value).first.try(:id)
        if game_id.nil?
          game_id = Game.where(year: @year, week: week.last, home_team_id: value).first.try(:id)
        end

        # attempt to update
        if !current_user.is_team_available?(@year, week.last, value) ||
            !pick.update_attributes(:user_id => current_user.id, :game_id => game_id, :team_id => value, :week => week.last, :year => @year)
          return redirect_to "/fooicide?year=#{@year}&week=#{week.last}", alert: 'Team already chosen'
        end
      end
    end

    redirect_to "/fooicide?year=#{@year}&week=#{@week}", notice: 'Your picks were successfully updated.'
  end

private

  def load_fooicide_pick
    @fooicide_pick = FooicidePick.find(params[:id])
  end

  def fooicide_pick_params
    params.require(:fooicide_pick).permit :game_id, :team_id, :user_id, :week, :year, :win
  end
end
