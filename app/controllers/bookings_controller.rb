class BookingsController < ApplicationController
  before_filter :authenticate_user! 
  load_and_authorize_resource
  before_filter :store_location, :only => [:new, :edit, :destroy]
  # GET /bookings
  # GET /bookings.json

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bookings }
    end
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/new
  # GET /bookings/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking.user = current_user

    respond_to do |format|
      if @booking.save
        format.html { redirect_back_or_default(calendar_path, notice: 'Booking was successfully created.') }
        format.json { render json: @booking, status: :created, location: @booking }
      else
        format.html { render action: "new" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bookings/1
  # PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_back_or_default(calendar_path, notice: 'Booking was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_back_or_default(calendar_path, notice: 'Booking was successfully deleted.') }
      format.json { head :ok }
    end
  end
end
