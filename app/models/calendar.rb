class Calendar
  attr_accessor :bookings
  attr_accessor :start_date
  attr_accessor :end_date
  def initialize(starts, ends)
    starts ||= Date.today
    ends ||= Date.today + 4.weeks
    self.bookings = Booking.where("starts_at <= :ends and ends_at >= :starts", 
                                  :ends => ends.to_datetime, 
                                  :starts => starts.to_datetime).order(:starts_at)
    self.start_date = starts.to_date
    self.end_date = ends.to_date
  end

  def entry_for?(machine_id, date)
    entries_for(machine_id, date).any?
  end

  def entries_for(machine_id, date)
    bookings.collect{|b| b if b.machine_id == machine_id && b.includes?(date)}.compact
  end
end
