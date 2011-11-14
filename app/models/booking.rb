class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :machine

  def includes?(date)
    starts_at.to_date <= date && ends_at.to_date >= date
  end

  def first_day?(date)
    date == starts_at.to_date
  end
  alias :starts_at? :first_day?

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
