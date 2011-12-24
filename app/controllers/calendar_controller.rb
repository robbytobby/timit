class CalendarController < ApplicationController
  def index
    machine_ids = []
    params[:machines].each_pair{|key, value| machine_ids << key.to_i if value == '1'} if params[:machines]
    @calendar = Calendar.new(params[:start_date], params[:end_date], machine_ids, params[:machine_offset])
  end
end
