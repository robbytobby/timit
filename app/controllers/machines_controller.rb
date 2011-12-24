class MachinesController < ApplicationController
  load_and_authorize_resource

  # GET /machines
  # GET /machines.json
  def index
    @machines = Machine.order(:name)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @machines }
    end
  end

  # GET /machines/1
  # GET /machines/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @machine }
    end
  end

  # GET /machines/new
  # GET /machines/new.json
  def new
    @options = Option.order(:name)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @machine }
    end
  end

  # GET /machines/1/edit
  def edit
    @options = Option.order(:name)
  end

  # POST /machines
  # POST /machines.json
  def create
    respond_to do |format|
      if @machine.save
        format.html { redirect_to machines_path, notice: t('controller.success.create', :thing => t('activerecord.models.machine')) }
        format.json { render json: @machine, status: :created, location: @machine }
      else
        format.html { render action: "new" }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /machines/1
  # PUT /machines/1.json
  def update
    respond_to do |format|
      if @machine.update_attributes(params[:machine])
        format.html { redirect_to machines_path, notice: t('controller.success.update', :thing => t('activerecord.models.machine')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /machines/1
  # DELETE /machines/1.json
  def destroy
    @machine.destroy

    respond_to do |format|
      format.html { redirect_to machines_url, notice: t('controller.success.destroy', :thing => t('activerecord.models.machine'))  }
      format.json { head :ok }
    end
  end
end
