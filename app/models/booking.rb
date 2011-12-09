class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :machine

  validates_presence_of :user_id
  validates_presence_of :machine_id
  validate :end_after_start
  validate :no_overlaps

  before_validation :adjust_time_to_all_day

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
  alias :ends_at? :last_day?

  def multiday?
    starts_at.to_date != ends_at.to_date
  end

  def all_day?
    all_day || (from_beginning_of_day? && till_end_of_day?)
  end

  def number_of_days
    (ends_at.to_date - starts_at.to_date + 1).to_i
  end

  def days
    starts_at.to_date..ends_at.to_date
  end

  def human_start(format = :default)
    if all_day
      I18n.l starts_at.to_date, :format => format
    else
      I18n.l starts_at, :format => format
    end
  end

  def human_end(format = :default)
    if all_day
      I18n.l ends_at.to_date, :format => format
    else
      I18n.l ends_at, :format => format
    end
  end

  def till_end_of_day?
    ends_at.end_of_day - ends_at < 1.hour
  end

  def from_beginning_of_day?
    starts_at - starts_at.beginning_of_day < 1.hour
  end

  def leaves_time_till?(booking)
    return true if booking.nil?
    booking.starts_at - ends_at >= 1.hour
  end

  def starts_long_after?(booking)
    return true if booking.nil?
    starts_at - booking.ends_at >= 1.hour
  end

  def next
    Booking.where(:machine_id => machine_id).
      where("starts_at >= :time", :time => ends_at).
      order(:starts_at).
      first
  end

  def prev
    Booking.where(:machine_id => machine_id).
      where("ends_at <= :time", :time => starts_at).
      order(:starts_at).
      first
  end

  def book_after_ok?
    leaves_time_till?(self.next) && !till_end_of_day?
  end

  def book_before_ok?
    starts_long_after?(self.prev) && !from_beginning_of_day?
  end


  private
  def end_after_start
    errors.add(:ends_at, :start_after_end) unless ends_at > starts_at
  end

  def no_overlaps
    date_conflict(:starts_at, "starts_at <= :start and ends_at > :start")
    date_conflict(:ends_at, "starts_at < :end and ends_at > :end")
    date_conflict(:ends_at, "starts_at >= :start and ends_at <= :end")
  end

  def date_conflict(attr, condition)
    conflicts = Booking.where("machine_id = :machine", :machine => machine_id)
    conflicts = conflicts.where("id != :id", :id => id) unless self.new_record?
    conflicts = conflicts.where(condition, :start => starts_at, :end => ends_at)
    conflicts.each{|c| errors.add(attr, :date_conflicts, :from => c.human_start, :to => c.human_end)}
  end

  def adjust_time_to_all_day
    if all_day
      self.starts_at = starts_at.beginning_of_day
      self.ends_at = ends_at.end_of_day
    end
  end

end
