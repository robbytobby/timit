class CalendarController < ApplicationController
  def index
    @calendar = Calendar.new(params[:start_date], params[:end_date])
    @machines = Machine.order(:id)
  end
end
