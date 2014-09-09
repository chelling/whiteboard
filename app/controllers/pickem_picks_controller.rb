class PickemPicksController < ApplicationController
  # GET /pickem_picks
  # GET /pickem_picks.json
  def index
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_picks = PickemPick.all
    authorize! :manage, @pickem_picks

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pickem_picks }
    end
  end

  # GET /pickem_picks/1
  # GET /pickem_picks/1.json
  def show
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_pick = PickemPick.find(params[:id])
    authorize! :manage, @pickem_pick

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pickem_pick }
    end
  end

  # GET /pickem_picks/new
  # GET /pickem_picks/new.json
  def new
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_pick = PickemPick.new
    authorize! :create, @pickem_pick

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pickem_pick }
    end
  end

  # GET /pickem_picks/1/edit
  def edit
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_pick = PickemPick.find(params[:id])
    authorize! :update, @pickem_pick
  end

  # POST /pickem_picks
  # POST /pickem_picks.json
  def create
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_pick = PickemPick.new(params[:pickem_pick])
    authorize! :create, @pickem_pick

    respond_to do |format|
      if @pickem_pick.save
        format.html { redirect_to @pickem_pick, notice: 'Pickem pick was successfully created.' }
        format.json { render json: @pickem_pick, status: :created, location: @pickem_pick }
      else
        format.html { render action: "new" }
        format.json { render json: @pickem_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pickem_picks/1
  # PUT /pickem_picks/1.json
  def update
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_pick = PickemPick.find(params[:id])
    authorize! :update, @pickem_pick

    respond_to do |format|
      if @pickem_pick.update_attributes(params[:pickem_pick])
        format.html { redirect_to @pickem_pick, notice: 'Pickem pick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pickem_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pickem_picks/1
  # DELETE /pickem_picks/1.json
  def destroy
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @pickem_pick = PickemPick.find(params[:id])
    authorize! :destroy, @pickem_pick
    @pickem_pick.destroy

    respond_to do |format|
      format.html { redirect_to pickem_picks_url }
      format.json { head :no_content }
    end
  end

  def scores
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @mobile_header = "Pigskin Pickem"
    @year = Time.now.year
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]

    # create account if it doesn't exist
    if current_user.accounts.find_by_year(@year).nil?
      authorize! :create, Account
      Account.create(:user_id => current_user.id, :year => @year, :amount => 0)
    end

    @games = Game.order("date ASC").find_all_by_year_and_week(@year, @week)
    @pickem_picks = current_user.pickem_picks_by_year_and_week(@year, @week)
    authorize! :read, @pickem_picks
    @users = User.order_all_by_account_amount(@year, @week)
    # get bye teams
    team_ids = []
    @games.try(:map) do |game|
      team_ids << game.away_team_id unless team_ids.include?(game.away_team_id)
      team_ids << game.home_team_id unless team_ids.include?(game.home_team_id)
    end
    (Team.all.map(&:id) - team_ids).try(:map) do |team_id|
      team = Team.find(team_id)
      if @bye_teams.nil?
        @bye_teams = "#{team.location}"
      else
        @bye_teams += ", #{team.location}"
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pickem_picks }
    end
  end
  
  # add picks to user table
  def update_picks
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @year = Time.now.year
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]

    # loop through params to find game
    params.each do |key,value|
      game = key.split('_')
      if game.first == "game"
        pick = PickemPick.find_by_user_id_and_game_id(current_user.id, game.last)
        if !pick.nil?
          authorize! :update, pick
        else
          pick = PickemPick.new
          authorize! :create, pick
        end

        if !pick.update_attributes(:user_id => current_user.id, :game_id => game.last, :team_id => value, :week => week.last, :year => @year)
          return redirect_to "/pickem?year=#{@year}&week=#{week.last}", alert: 'Error while updating your picks.'
        end
      end

      # set wagers as well for single picks
      if game.first == "wager" && !value.empty?

        pick = PickemPick.find_by_user_id_and_game_id(current_user.id, game.last)
        if pick.nil?
          return redirect_to "/pickem?year=#{@year}&week=#{week.last}", alert: 'Cannot bet without making a pick'
        elsif pick.game.in_progress_or_complete?
          return redirect_to "/pickem?year=#{@year}&week=#{week.last}", alert: 'Cannot bet when game is in progress'
        end
        authorize! :update, pick

        wager = current_user.wagers.where("pickem_pick_id = ?", pick.id).try(:first)
        if !wager.nil?
          authorize! :update, wager
        else
          wager = Wager.new
          authorize! :create, wager
        end

        if !wager.update_attributes(:account_id => current_user.accounts.find_by_year(@year).try(:id), :pickem_pick_id => pick.id, :amount => value)
          return redirect_to "/pickem?year=#{@year}&week=#{week.last}", alert: 'Error while updating your wagers.'
        end
      end
    end
    
    redirect_to "/pickem?year=#{@year}&week=#{week.last}", notice: 'Your picks were successfully updated.'
  end

  # User stats
  def stats
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end

    @year = Time.now.year
    @year = params[:year] if params[:year]
  end

  # Update games
  def update_games
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @game = Game.new

    authorize! :update, @game
    @year = Time.now.year
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]

    Game.create_or_update_games(@year, @week)
    redirect_to "/pickem?year=#{@year}&week=#{@week}", notice: 'Games successfully updated.'
  end
end
