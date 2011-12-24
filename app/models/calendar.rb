class Calendar
  attr_accessor :bookings
  attr_accessor :days
  attr_accessor :machines
  attr_accessor :machine_offset
  private :machines=, :days=, :bookings=, :machine_offset=

  def initialize(starts = nil, ends = nil, machine_ids = [], machine_offset = 0)
    starts ||= Date.today
    ends ||= (starts.to_date + 4.weeks)
    self.machine_offset = machine_offset.to_i ||= 0
    self.bookings = Booking.where("starts_at <= :ends and ends_at >= :starts", 
                                  :ends => ends.to_datetime, 
                                  :starts => starts.to_datetime).order(:starts_at)
    self.days = starts.to_date...ends.to_date
    self.machines = machine_ids.any? ? Machine.order(:name).find(machine_ids) : Machine.order(:name)
  end

  def entries_for(machine_id, date)
    bookings.collect{|b| b if b.machine_id == machine_id && b.includes?(date)}.compact
  end

  def draw_new_booking_first?(machine_id, date)
    first = entries_for(machine_id, date).first
    return false if first && (first.all_day? || !first.starts_at?(date) || !first.book_before_ok?)
    return true
  end

  def draw_new_booking_after?(booking, date)
    return true if booking.ends_at?(date) && booking.book_after_ok?
    return false
  end

  def draw_new_booking_after_mulitday?(booking, date)
    return false if draw_booking?(booking,date)
    return true if booking.multiday? && !booking.all_day? && booking.ends_at?(date) && booking.book_after_ok?
    return false
  end

  def draw_booking?(booking, date)
    booking.starts_at?(date) || date == days.first
  end

  def number_of_entries(machine_id, date)
    n = 0
    n += 1 if draw_new_booking_first?(machine_id, date)
    entries_for(machine_id, date).each{ |b| n += draw_new_booking_after?(b, date) ? 2 : 1 }
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
