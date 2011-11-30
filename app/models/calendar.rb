class Calendar
  attr_accessor :bookings
  attr_accessor :days
  attr_accessor :machines
  private :machines=, :days=, :bookings=

  def initialize(starts = nil, ends = nil, machine_ids = nil)
    starts ||= Date.today
    ends ||= (starts.to_date + 4.weeks)
    self.bookings = Booking.where("starts_at <= :ends and ends_at >= :starts", 
                                  :ends => ends.to_datetime, 
                                  :starts => starts.to_datetime).order(:starts_at)
    self.days = starts.to_date...ends.to_date
    self.machines = machine_ids ? Machine.order(:id).find(machine_ids) : Machine.order(:id)
  end

  def entries_for(machine_id, date)
    bookings.collect{|b| b if b.machine_id == machine_id && b.includes?(date)}.compact
  end

  def draw_new_booking_first?(machine_id, date)
    if first = entries_for(machine_id, date).first
      if first.starts_at?(date)
        return false if first.starts_at - date.to_datetime < 1.hour
      else
        return false
      end
      return false if first.all_day
    end
    return true
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
  
  def number_of_entries(machine_id, date)
    n = entries_for(machine_id, date).size
    n += 1 if draw_new_booking_link?(machine_id, date)
    n
  end

  def max_entries(date)
    machines.collect{|m| number_of_entries(m.id, date)}.max
  end

  def next
    days.last
  end

  def prev
    days.first - 4.weeks
  end
end
