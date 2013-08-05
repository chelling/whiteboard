class PickemPicksController < ApplicationController
  # GET /pickem_picks
  # GET /pickem_picks.json
  def index
    @pickem_picks = PickemPick.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pickem_picks }
    end
  end

  # GET /pickem_picks/1
  # GET /pickem_picks/1.json
  def show
    @pickem_pick = PickemPick.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pickem_pick }
    end
  end

  # GET /pickem_picks/new
  # GET /pickem_picks/new.json
  def new
    @pickem_pick = PickemPick.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pickem_pick }
    end
  end

  # GET /pickem_picks/1/edit
  def edit
    @pickem_pick = PickemPick.find(params[:id])
  end

  # POST /pickem_picks
  # POST /pickem_picks.json
  def create
    @pickem_pick = PickemPick.new(params[:pickem_pick])

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
    @pickem_pick = PickemPick.find(params[:id])

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
    @pickem_pick = PickemPick.find(params[:id])
    @pickem_pick.destroy

    respond_to do |format|
      format.html { redirect_to pickem_picks_url }
      format.json { head :no_content }
    end
  end
end
