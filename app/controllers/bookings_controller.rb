class BookingsController < ApplicationController
  load_and_authorize_resource
  before_filter :store_location, only: [:new, :edit, :destroy]
  after_filter :show_messages, only: [:create, :update]

  def index
    @bookings = Booking.order(:starts_at)
    respond_to do |format|
      format.html 
      format.json { render json: @bookings }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @booking }
    end
  end

  def new
    redirect_to(calendar_path, notice: t('controller.bookings.machine_needed')) and return unless @booking.machine
    respond_to do |format|
      format.html 
      format.json { render json: @booking }
    end
  end

  def edit
  end

  def create
    respond_to do |format|
      if @booking.save
        format.html { redirect_back_or_default(calendar_path, notice: t('controller.success.create', :thing => I18n.t('activerecord.models.booking'))) } 
        format.json { render json: @booking, status: :created, location: @booking }
      else
        format.html { render action: "new" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_back_or_default(calendar_path, notice: t('controller.success.update', :thing => I18n.t('activerecord.models.booking'))) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_back_or_default(calendar_path, notice: t('controller.success.destroy', :thing => I18n.t('activerecord.models.booking'))) }
      format.json { head :ok }
    end
  end

  private
  def show_messages
    @booking.options.each do |option|
      flash[:notice] ||= ''
      flash[:notice] += "\n" + option.message unless option.message.blank?
    end if @booking.valid?
  end
end
