module CalendarHelper
  def row_class(calendar, day)
    "day#{day.wday} #{cycle('odd', 'even')} height-#{calendar.max_entries(day)}"
  end

  def div_class(calendar, booking)
    klass = "booked"
    klass << " #{div_height(calendar, booking)}"
    if booking.multiday?
      klass << " multiday"
      klass << " all_day" if booking.all_day
    end
    klass
  end

  def div_height(calendar, booking)
    n = 0
    m = 0
    booking.days.each do |d| 
      next if d < calendar.days.first || d >= calendar.days.last
      if booking.last_day?(d)
        add = booking.all_day ? calendar.max_entries(d) : 1
      else
        add = calendar.max_entries(d) - calendar.number_of_entries(booking.machine_id, d) + 1
      end
      n += add
      m += add - 1
    end
    "height-#{n}-#{m}"
  end

  def new_booking(machine, day)
    content_tag(:div, link_to('+', new_booking_path(:booking => {:machine_id => machine, :starts_at => day.to_datetime})), :class => "free")
  end

  def draw_booking(calendar, booking, day)
    if booking.first_day?(day) || day == calendar.days.first
      content_tag(:div,
                  link_to( booking.user.email, edit_booking_path(booking)),
                  :class => div_class(@calendar, booking))
    end
  end

  def draw_spacer(calendar, machine_id, day)
    first = @calendar.entries_for(machine_id, day).first 
    content_tag(:div, '', :class => 'spacer') if first && first.multiday? && first.days.last == day
  end
end
