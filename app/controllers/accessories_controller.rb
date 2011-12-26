class AccessoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @accessories = Accessory.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accessories }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @accessory }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @accessory }
    end
  end

  def edit
  end

  def create
    respond_to do |format|
      if @accessory.save
        format.html { redirect_to accessories_path, notice: t('controller.success.create', :thing => t('activerecord.models.accessory')) }
        format.json { render json: @accessory, status: :created, location: @accessory }
      else
        format.html { render action: "new" }
        format.json { render json: @accessory.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @accessory.update_attributes(params[:accessory])
        format.html { redirect_to accessories_path, notice: t('controller.success.update', :thing => t('activerecord.models.accessory')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @accessory.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @accessory.destroy

    respond_to do |format|
      format.html { redirect_to accessories_url, notice: t('controller.success.destroy', :thing => t('activerecord.models.accessory'))  }
      format.json { head :ok }
    end
  end
end
