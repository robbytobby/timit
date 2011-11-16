class CalendarController < ApplicationController
  before_filter :authenticate_user! 
  def index
    @calendar = Calendar.new(params[:start_date], params[:end_date], params[:machines])
  end
end
