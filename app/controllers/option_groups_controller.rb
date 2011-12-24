class OptionGroupsController < ApplicationController
  before_filter :authenticate_user! 
  load_and_authorize_resource

  # GET /option_groups
  # GET /option_groups.json
  def index
    @option_groups = OptionGroup.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @option_groups }
    end
  end

  # GET /option_groups/1
  # GET /option_groups/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @option_group }
    end
  end

  # GET /option_groups/new
  # GET /option_groups/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @option_group }
    end
  end

  # GET /option_groups/1/edit
  def edit
    @option_group.options.build
  end

  # POST /option_groups
  # POST /option_groups.json
  def create
    respond_to do |format|
      if @option_group.save
        format.html { redirect_to option_groups_path, notice: 'Option group was successfully created.' }
        format.json { render json: @option_group, status: :created, location: @option_group }
      else
        format.html { render action: "new" }
        format.json { render json: @option_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /option_groups/1
  # PUT /option_groups/1.json
  def update
    respond_to do |format|
      if @option_group.update_attributes(params[:option_group])
        format.html { redirect_to option_groups_path, notice: 'Option group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @option_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /option_groups/1
  # DELETE /option_groups/1.json
  def destroy
    @option_group.destroy

    respond_to do |format|
      format.html { redirect_to option_groups_url }
      format.json { head :ok }
    end
  end
end
