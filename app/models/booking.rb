class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :machine

  validates_presence_of :user_id
  validates_presence_of :machine_id
  validate :end_after_start
  validate :no_overlaps

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

  def number_of_days
    (ends_at.to_date - starts_at.to_date + 1).to_i
  end

  def days
    starts_at.to_date..ends_at.to_date
  end

  private
  def end_after_start
    errors.add(:ends_at, :start_after_end) unless ends_at > starts_at
  end

  def no_overlaps
    rel = Booking.where("machine_id = :machine", :machine => machine_id)
    rel = rel.where("id != :id", :id => id) unless self.new_record?
    if b = rel.where("starts_at <= :start and ends_at > :start", :start => starts_at)
      date_conflict(:starts_at, b)
    end
    if b = rel.where("starts_at < :end and ends_at > :end", :end => ends_at)
      date_conflict(:ends_at, b)
    end
    if b = rel.where("starts_at >= :start and ends_at <= :end", :start => starts_at, :end => ends_at)
      date_conflict(:ends_at, b)
    end
  end

  def date_conflict(attr, records)
    records.each do |r|
      errors.add(attr, :date_conflicts, :start => I18n.l(r.starts_at, :format => :short), :end => I18n.l(r.ends_at, :format => :short))
    end
  end
end
