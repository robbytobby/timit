class Calendar
  attr_accessor :bookings
  attr_accessor :days
  attr_accessor :machines
  def initialize(starts, ends, machine_ids)
    starts ||= Date.today
    ends ||= Date.today + 4.weeks
    self.bookings = Booking.where("starts_at <= :ends and ends_at >= :starts", 
                                  :ends => ends.to_datetime, 
                                  :starts => starts.to_datetime).order(:starts_at)

    self.days = starts.to_date...ends.to_date

    if machine_ids
      self.machines = Machine.find(machine_ids).order(:id)
    else
      self.machines = Machine.order(:id)
    end
  end

  def entries_for(machine_id, date)
    bookings.collect{|b| b if b.machine_id == machine_id && b.includes?(date)}.compact
  end

  def draw_new_booking_first?(machine_id, date)
    #if first = entries_for(machine_id, date).first
    #  return false unless first.starts_at?(date)
    #  return false if first.all_day
    #end
    #return true

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
  
  def number_of_entries(machine_id, date)
    n = entries_for(machine_id, date).size
    n += 1 if draw_new_booking_link?(machine_id, date)
    n
  end

  def max_entries(date)
    machines.collect{|m| number_of_entries(m.id, date)}.max
  end
end
