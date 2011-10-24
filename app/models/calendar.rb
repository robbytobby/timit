class Calendar
  attr_accessor :bookings
  attr_accessor :start_date
  attr_accessor :end_date
  def initialize(starts, ends)
    starts ||= Date.today - 1.week
    ends ||= Date.today + 3.weeks
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

  def draw_new_booking_first?(machine_id, date)
    value = true
    if first = entries_for(machine_id, date).first
      value = false unless first.starts_at.to_date == date
      value = false if first.all_day
    end
    return value
  end

  def draw_new_booking_last?(machine_id, date)
    return false if draw_new_booking_first?(machine_id, date)
    if last = entries_for(machine_id, date).last
      return true if  last.ends_at.to_date == date && !last.all_day
    end
    return false
  end

  def draw_new_booking_link?(machine_id, date)
    draw_new_booking_first?(machine_id, date) || draw_new_booking_last?(machine_id, date)
  end
  
  def number_of_divs(machine_id, date)
    n = entries_for(machine_id, date).size
    n += 1 if draw_new_booking_link?(machine_id, date)
    n
  end

  def max_number_of_divs(machines, date)
    machines.collect{|m| number_of_divs(m.id, date)}.max
  end

  def number_of_spacers(machine_id, date, machines)
    if last = entries_for(machine_id, date).last
      lasttype = last.day_type(date).split(' ')
      return 0 unless lasttype.include?('firstday') || lasttype.include?('middle')
      return max_number_of_divs(machines, date) - number_of_divs(machine_id, date)
    else
      return 0
    end
  end
end
