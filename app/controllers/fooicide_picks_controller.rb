class FooicidePicksController < ApplicationController
  # GET /fooicide_picks
  # GET /fooicide_picks.json
  def index
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_picks = FooicidePick.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fooicide_picks }
    end
  end

  # GET /fooicide_picks/1
  # GET /fooicide_picks/1.json
  def show
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_pick = FooicidePick.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fooicide_pick }
    end
  end

  # GET /fooicide_picks/new
  # GET /fooicide_picks/new.json
  def new
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_pick = FooicidePick.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fooicide_pick }
    end
  end

  # GET /fooicide_picks/1/edit
  def edit
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_pick = FooicidePick.find(params[:id])
  end

  # POST /fooicide_picks
  # POST /fooicide_picks.json
  def create
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_pick = FooicidePick.new(params[:fooicide_pick])

    respond_to do |format|
      if @fooicide_pick.save
        format.html { redirect_to @fooicide_pick, notice: 'Fooicide pick was successfully created.' }
        format.json { render json: @fooicide_pick, status: :created, location: @fooicide_pick }
      else
        format.html { render action: "new" }
        format.json { render json: @fooicide_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fooicide_picks/1
  # PUT /fooicide_picks/1.json
  def update
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_pick = FooicidePick.find(params[:id])

    respond_to do |format|
      if @fooicide_pick.update_attributes(params[:fooicide_pick])
        format.html { redirect_to @fooicide_pick, notice: 'Fooicide pick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fooicide_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fooicide_picks/1
  # DELETE /fooicide_picks/1.json
  def destroy
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @fooicide_pick = FooicidePick.find(params[:id])
    @fooicide_pick.destroy

    respond_to do |format|
      format.html { redirect_to fooicide_picks_url }
      format.json { head :no_content }
    end
  end

  def scores
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @year = '2013'
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]
    @games = Game.order("date ASC").find_all_by_year_and_week(@year, @week)
    @pickem_picks = current_user.pickem_picks_by_year_and_week(@year, @week)
    @users = User.all
  end
  
  def rules
  end

  # add picks to user table
  def update_picks
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @year = '2013'
    @week = find_week
    @year = params[:year] if params[:year]
    @week = params[:week] if params[:week]

    params.each do |key,value|
      game = key.split('_')
      if game.first == "game"
        pick = PickemPick.find_by_user_id_and_game_id(current_user.id, game.last) || PickemPick.new
        authorize! :update, pick
        if !pick.update_attributes(:user_id => current_user.id, :game_id => game.last, :team_id => value, :week => @week, :year => @year)
          return redirect_to "/pickem?year=#{@year}&week=#{@week}", alert: 'Error while updating your picks.'
        end
      end
    end

    redirect_to "/pickem?year=#{@year}&week=#{@week}", notice: 'Your picks were successfully updated.'
  end
end
