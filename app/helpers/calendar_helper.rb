module CalendarHelper
  def row_class(calendar, day)
    klass = "day#{day.wday} #{cycle('even', 'odd')} height-#{calendar.max_entries(day)}"
    klass << " last" if day == calendar.days.last - 1.day
    klass 
  end

  def div_class(calendar, booking)
    klass = ""
    klass << " #{div_height(calendar, booking)}"
    klass << " multiday" if booking.multiday? && !booking.ends_at?(calendar.days.first)
    klass << " all_day" if booking.all_day? 
    klass << " from_midnight" if booking.from_beginning_of_day? ||  booking.starts_at.to_date < calendar.days.first && (booking.multiday? && !booking.ends_at?(calendar.days.first)) 
    klass << " end" if  booking.includes?(calendar.days.first) && booking.multiday? && !booking.starts_at?(calendar.days.first)
    klass << " start" if  booking.includes?(calendar.days.last - 1.day) && booking.multiday? && !booking.ends_at?(calendar.days.last - 1.day)
    klass << " " + booking.user.role
    klass
  end

  def div_height(calendar, booking)
    n = 0
    m = 0
    booking.days.each do |d| 
      next if d < calendar.days.first || d >= calendar.days.last
      if booking.includes?(d) && booking.ends_at?(d) && !booking.till_end_of_day?
        add = booking.all_day? ? calendar.max_entries(d) : 1
      else
        add = calendar.max_entries(d) - calendar.number_of_entries(booking.machine_id, d) + 1
      end
      n += add
      m += add - 1
    end
    "height-#{n}-#{m}"
  end

  def new_booking_link(machine, day, opts = {})
    starts_at = opts[:after]  ? opts[:after].ends_at : day.to_datetime
    next_booking = Booking.next(machine, starts_at)
    starts_at += 8.hours unless opts[:after] || (next_booking && next_booking.starts_at < starts_at + 8.hours + machine.min_duration)
    ends_at = starts_at + machine.min_duration
    link_to('+', new_booking_path(:booking => {:machine_id => machine, :starts_at => starts_at, :ends_at => ends_at, :user_id => current_user}))
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
    opts.delete_if{|key, value| value.blank? || value == 0}
    link_to name, calendar_path(opts), html
  end

  def prev_machine_link?
    @calendar.machine_offset > 0
  end

  def next_machine_link?(machine, index)
    add = APPLICATION['calendar']['max_machines'] - 1
    index == @calendar.machine_offset + add && @calendar.machines.size > @calendar.machine_offset + add && machine != @calendar.machines.last
  end

  def draw_machine?(i)
    i >= @calendar.machine_offset && i < @calendar.machine_offset + APPLICATION['calendar']['max_machines'] 
  end
end
