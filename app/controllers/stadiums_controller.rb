class StadiumsController < ApplicationController
  # GET /stadiums
  # GET /stadiums.json
  def index
    @stadiums = Stadium.all
    authorize! :manage, @stadiums

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stadiums }
    end
  end

  # GET /stadiums/1
  # GET /stadiums/1.json
  def show
    @stadium = Stadium.find(params[:id])
    authorize! :manage, @stadium

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stadium }
    end
  end

  # GET /stadiums/new
  # GET /stadiums/new.json
  def new
    @stadium = Stadium.new
    authorize! :manage, @stadium

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stadium }
    end
  end

  # GET /stadiums/1/edit
  def edit
    @stadium = Stadium.find(params[:id])
    authorize! :update, @stadium
  end

  # POST /stadiums
  # POST /stadiums.json
  def create
    @stadium = Stadium.new(params[:stadium])
    authorize! :manage, @stadium

    respond_to do |format|
      if @stadium.save
        format.html { redirect_to @stadium, notice: 'Stadium was successfully created.' }
        format.json { render json: @stadium, status: :created, location: @stadium }
      else
        format.html { render action: "new" }
        format.json { render json: @stadium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stadiums/1
  # PUT /stadiums/1.json
  def update
    @stadium = Stadium.find(params[:id])
    authorize! :manage, @stadium
    respond_to do |format|
      if @stadium.update_attributes(params[:stadium])
        format.html { redirect_to @stadium, notice: 'Stadium was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stadium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stadiums/1
  # DELETE /stadiums/1.json
  def destroy
    @stadium = Stadium.find(params[:id])
    authorize! :manage, @stadium
    @stadium.destroy

    respond_to do |format|
      format.html { redirect_to stadiums_url }
      format.json { head :no_content }
    end
  end
end
