class Calendar
  attr_accessor :bookings
  attr_accessor :start_date
  attr_accessor :end_date
  attr_accessor :machines
  def initialize(starts, ends, machine_ids)
    starts ||= Date.today - 1.week
    ends ||= Date.today + 3.weeks
    self.bookings = Booking.where("starts_at <= :ends and ends_at >= :starts", 
                                  :ends => ends.to_datetime, 
                                  :starts => starts.to_datetime).order(:starts_at)
    self.start_date = starts.to_date
    self.end_date = ends.to_date
    if machine_ids
      self.machines = Machine.find(machin_ids).order(:id)
    else
      self.machines = Machine.order(:id)
    end

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
  
  def number_of_entries(machine_id, date)
    n = entries_for(machine_id, date).size
    n += 1 if draw_new_booking_link?(machine_id, date)
    n
  end

  def max_entries(date)
    machines.collect{|m| number_of_entries(m.id, date)}.max
  end

  def row_height(day)
    n = max_entries(day) * 22
    n.to_s + 'px'
  end

  def div_height(booking)
    n = 0
    (booking.starts_at.to_date..booking.ends_at.to_date).each do |d|
      if booking.first_day?(d) || booking.last_day?(d)
        n += max_entries(d) - number_of_entries(booking.machine_id, d) + 1
      else
        n += max_entries(d)
      end
    end
    (n * 22 - 5).to_s + 'px'
  end

  def free_spacing(machine_id, day)
    if entries_for(machine_id, day).first.multiday?
      n = max_entries(day) - number_of_entries(machine_id, day) + 1
      "top: #{n * 22}px"
    else
      ""
    end
  end

  def spacing(booking)
    all_entries = entries_for(booking.machine_id, booking.starts_at.to_date)
    i = all_entries.index(booking)
    if i > 0 && all_entries[i-1].multiday?
      n = max_entries(booking.starts_at.to_date) - 2
      "top: #{n * 22}px"
    else
      ""
    end
  end
end
