class WinPoolPicksController < ApplicationController
  # GET /win_pool_picks
  # GET /win_pool_picks.json
  def index
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
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
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @win_pool_pick = WinPoolPick.find(params[:id])
    authorize! :manage, @win_pool_pick

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @win_pool_pick }
    end
  end

  # GET /win_pool_picks/new
  # GET /win_pool_picks/new.json
  def new
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @win_pool_pick = WinPoolPick.new
    authorize! :create, @win_pool_pick

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @win_pool_pick }
    end
  end

  # GET /win_pool_picks/1/edit
  def edit
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @win_pool_pick = WinPoolPick.find(params[:id])
    authorize! :update, @win_pool_pick
  end

  # POST /win_pool_picks
  # POST /win_pool_picks.json
  def create
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
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
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @win_pool_pick = WinPoolPick.find(params[:id])
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
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @win_pool_pick = WinPoolPick.find(params[:id])
    authorize! :destroy, @win_pool_pick
    @win_pool_pick.destroy

    respond_to do |format|
      format.html { redirect_to win_pool_picks_url }
      format.json { head :no_content }
    end
  end

  def win_pool
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
  end

  def pick_team
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
    @win_pool_pick = WinPoolLeague.find(params[:id]).win_pool_picks.find_by_user_id(current_user.id)
    authorize! :update, @win_pool_pick
  end
end
