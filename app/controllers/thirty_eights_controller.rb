class ThirtyEightsController < ApplicationController
  # GET /thirty_eights
  # GET /thirty_eights.json
  def index
    @thirty_eights = ThirtyEight.all
    authorize! :manage, @thirty_eights

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @thirty_eights }
    end
  end

  # GET /thirty_eights/1
  # GET /thirty_eights/1.json
  def show
    @thirty_eight = ThirtyEight.find(params[:id])
    authorize! :manage, @thirty_eight

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thirty_eight }
    end
  end

  # GET /thirty_eights/new
  # GET /thirty_eights/new.json
  def new
    @thirty_eight = ThirtyEight.new
    authorize! :create, @thirty_eight

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @thirty_eight }
    end
  end

  # GET /thirty_eights/1/edit
  def edit
    @thirty_eight = ThirtyEight.find(params[:id])
    authorize! :update, @thirty_eight
  end

  # POST /thirty_eights
  # POST /thirty_eights.json
  def create
    @thirty_eight = ThirtyEight.new(params[:thirty_eight])
    authorize! :create, @thirty_eight

    respond_to do |format|
      if @thirty_eight.save
        format.html { redirect_to @thirty_eight, notice: 'Thirty eight was successfully created.' }
        format.json { render json: @thirty_eight, status: :created, location: @thirty_eight }
      else
        format.html { render action: "new" }
        format.json { render json: @thirty_eight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /thirty_eights/1
  # PUT /thirty_eights/1.json
  def update
    @thirty_eight = ThirtyEight.find(params[:id])
    authorize! :update, @thirty_eight

    respond_to do |format|
      if @thirty_eight.update_attributes(params[:thirty_eight])
        format.html { redirect_to @thirty_eight, notice: 'Thirty eight was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @thirty_eight.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /thirty_eights/1
  # DELETE /thirty_eights/1.json
  def destroy
    @thirty_eight = ThirtyEight.find(params[:id])
    authorize! :destroy, @thirty_eight
    @thirty_eight.destroy

    respond_to do |format|
      format.html { redirect_to thirty_eights_url }
      format.json { head :no_content }
    end
  end

  def scores

  end

  def rules

  end
end
