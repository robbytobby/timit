class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :machine

  def includes?(date)
    starts_at.to_date <= date && ends_at.to_date >= date
  end

  def day_type(date)
    type = ['booked ']
    type << 'firstday' if date == starts_at.to_date
    type << 'lastday' if date == ends_at.to_date
    type << 'middle' if date != starts_at.to_date && date != ends_at.to_date
    return type.join(' ')
  end

  def first_day?(date)
    date == starts_at.to_date
  end

  def last_day?(date)
    date == ends_at.to_date
  end

  def multiday?
    starts_at.to_date != ends_at.to_date
  end

  def number_of_days
    (ends_at.to_date - starts_at.to_date + 1).to_i
  end

  def days
    starts_at.to_date..ends_at.to_date
  end
end
