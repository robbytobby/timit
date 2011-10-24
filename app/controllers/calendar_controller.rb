class CalendarController < ApplicationController
  def index
    @calendar = Calendar.new(params[:start_date], params[:end_date], params[:machines])
    @machines = Machine.order(:id)
  end
end
