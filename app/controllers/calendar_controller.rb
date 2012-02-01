class CalendarController < ApplicationController
  def index
    machine_ids = []
    if params[:machines]
      params[:machines].each_pair{|key, value| machine_ids << key.to_i if value == '1'} if params[:machines]
    elsif current_user.default_machines.any?
      current_user.default_machines.each{ |m| machine_ids << m.id }
    end
    @calendar = Calendar.new(params[:start_date], params[:end_date], machine_ids, params[:machine_offset])
  end
end
