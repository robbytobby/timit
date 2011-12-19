module CalendarHelper
  def row_class(calendar, day)
    "day#{day.wday} #{cycle('odd', 'even')} height-#{calendar.max_entries(day)}"
  end

  def div_class(calendar, booking)
    klass = ""
    klass << " #{div_height(calendar, booking)}"
    klass << " multiday" if booking.multiday? && !booking.ends_at?(calendar.days.first)
    klass << " all_day" if booking.all_day? 
    klass << " from_midnight" if booking.from_beginning_of_day? || booking.includes?(calendar.days.first) && booking.multiday? && !booking.ends_at?(calendar.days.first)
    klass << " end" if  booking.includes?(calendar.days.first) && booking.multiday? && !booking.starts_at?(calendar.days.first)
    klass << " start" if  booking.includes?(calendar.days.last - 1.day) && booking.multiday? && !booking.ends_at?(calendar.days.last - 1.day)
    klass
  end

  def div_height(calendar, booking)
    n = 0
    m = 0
    booking.days.each do |d| 
      next if d < calendar.days.first || d >= calendar.days.last
      if booking.ends_at?(d) && !booking.till_end_of_day?
        add = booking.all_day? ? calendar.max_entries(d) : 1
      else
        add = calendar.max_entries(d) - calendar.number_of_entries(booking.machine_id, d) + 1
      end
      n += add
      m += add - 1
    end
    "height-#{n}-#{m}"
  end

  def new_booking(machine, day, opts = {})
    if day >= Date.today
      starts_at = opts[:after]  ? opts[:after].ends_at : day.to_datetime
      next_booking = Booking.next(machine, starts_at)
      ends_at = next_booking.starts_at if next_booking
      max_duration = machine.real_max_duration 
      max_duration ||= 1.week
      ends_at = starts_at + max_duration if ends_at.nil? || ends_at > starts_at + max_duration

      content_tag(:div, link_to('+', new_booking_path(:booking => {:machine_id => machine, :starts_at => starts_at, :ends_at => ends_at, :user_id => current_user})), :class => "free")
    else
      content_tag(:div, ' ', :class => "free height-1-0")
    end
  end

  def draw_spacer(calendar, machine_id, day)
    return if day == calendar.days.first
    first = @calendar.entries_for(machine_id, day).first 
    content_tag(:div, '', :class => 'spacer') if first && first.multiday? && first.ends_at?(day) && !first.all_day? 
  end

  def calendar_link(name, opts = {}, html = {})
    opts[:machine_offset] ||= @calendar.machine_offset
    opts[:start_date] ||= @calendar.days.first
    opts[:machines] = {}
    @calendar.machines.each{|m| opts[:machines][m.id] = 1}
    link_to name, calendar_path(opts), html
  end
end
