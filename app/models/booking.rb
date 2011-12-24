class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :machine
  has_and_belongs_to_many :options

  validates_presence_of :user_id
  validates_numericality_of :user_id, :only_integer => true
  validates_presence_of :machine_id
  validates_numericality_of :machine_id, :only_integer => true
  validate :not_to_long
  validate :end_after_start
  validate :no_overlaps
  validate :non_optional_options
  validate :exclusive_options
  validates_numericality_of :temperature, :only_integer => true, :allow_blank => true
  validates :temperature, :presence => {:if => lambda{|b| b.machine ? b.machine.needs_temperature : false} }
  validates :sample, :presence => {:if => lambda{|b| b.machine ? b.machine.needs_sample : false} }


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

  def self.next(machine_id, after)
    Booking.where(:machine_id => machine_id).
      where("starts_at >= :time", :time => after).
      order(:starts_at).
      first
  end

  def next
    Booking.next(machine_id, ends_at)
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

  def group_errors(group)
    errors[:base].collect{|e| e if e.match(/#{group.name}/)}.compact || []
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

  def not_to_long
    if machine && machine.max_duration
      duration = ends_at - starts_at
      errors.add(:ends_at, :to_long, :max => I18n.t('human_time_units.' + machine.max_duration_unit, :count => machine.max_duration)) if duration > machine.real_max_duration
    end
  end

  def adjust_time_to_all_day
    if all_day
      self.starts_at = starts_at.beginning_of_day
      self.ends_at = ends_at.end_of_day
    end

    if ends_at == ends_at.beginning_of_day
      self.ends_at = ends_at - 1.minute
    end
  end

  def non_optional_options
    return unless machine
    machine.options.group_by(&:option_group).each do |group, opts|
      errors.add(:base, :one_necessary, :name => group.name) unless group.optional || (options & opts).any? 
    end
  end

  def exclusive_options
    return unless machine
    machine.options.group_by(&:option_group).each do |group, opts|
      errors.add(:base, :to_many, :name => group.name) if group.exclusive && (options & opts).many?
    end
  end
end
