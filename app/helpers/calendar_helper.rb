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
    else
      klass << " #{offset(calendar, booking.machine_id, booking.starts_at.to_date)}"
    end
    klass
  end

  def offset(calendar, machine_id, day)
    calendar.entries_for(machine_id, day).first.multiday? ? "offset" : ""
  end

  def div_height(calendar, booking)
    n = 0
    booking.days.each do |d| 
      if booking.last_day?(d)
        n += booking.all_day ? calendar.max_entries(d) : 1
      else
        n += calendar.max_entries(d) - calendar.number_of_entries(booking.machine_id, d) + 1
      end
    end
    "height-#{n}-#{n - booking.number_of_days}"
  end

  def new_booking(machine, day, extra_class = '')
    content_tag(:div, link_to('+', new_booking_path(:booking => {:machine_id => machine, :starts_at => day.to_datetime})), :class => "free #{extra_class}")
  end

  def draw_booking(calendar, booking, day)
    if booking.first_day?(day) || day == calendar.days.first
      content_tag(:div,
                  link_to( booking.user.email, edit_booking_path(booking)),
                  :class => div_class(@calendar, booking))
    else
      ""
    end
  end

end
