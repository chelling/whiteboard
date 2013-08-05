class FooicidePicksController < ApplicationController
  # GET /fooicide_picks
  # GET /fooicide_picks.json
  def index
    @fooicide_picks = FooicidePick.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fooicide_picks }
    end
  end

  # GET /fooicide_picks/1
  # GET /fooicide_picks/1.json
  def show
    @fooicide_pick = FooicidePick.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fooicide_pick }
    end
  end

  # GET /fooicide_picks/new
  # GET /fooicide_picks/new.json
  def new
    @fooicide_pick = FooicidePick.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fooicide_pick }
    end
  end

  # GET /fooicide_picks/1/edit
  def edit
    @fooicide_pick = FooicidePick.find(params[:id])
  end

  # POST /fooicide_picks
  # POST /fooicide_picks.json
  def create
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
    @fooicide_pick = FooicidePick.find(params[:id])
    @fooicide_pick.destroy

    respond_to do |format|
      format.html { redirect_to fooicide_picks_url }
      format.json { head :no_content }
    end
  end
end
