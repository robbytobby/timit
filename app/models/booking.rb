class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :machine
  has_and_belongs_to_many :options

  validates_presence_of :user_id
  validates_numericality_of :user_id, :only_integer => true
  validates_presence_of :machine_id
  validates_numericality_of :machine_id, :only_integer => true
  validates_presence_of :starts_at, :ends_at
  validate :not_to_long
  validate :not_to_short
  validate :end_after_start
  validate :no_overlaps
  validates_numericality_of :temperature, :only_integer => true, :allow_blank => true
  validates :temperature, :presence => {:if => lambda{|b| b.machine ? b.machine.needs_temperature : false} }
  validates :sample, :presence => {:if => lambda{|b| b.machine ? b.machine.needs_sample : false} }
  validate :non_optional_options
  validate :exclusive_options
  validate :needed_accessories_available
  validate :no_option_conflicts

  before_validation :adjust_time_to_all_day

  def includes?(date)
    overlaps?(date.beginning_of_day...date.end_of_day)
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
    if includes?(ends_at)
      starts_at.to_date..ends_at.to_date
    else
      starts_at.to_date...ends_at.to_date
    end
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
    ends_at.end_of_day - ends_at < machine.min_duration 
  end

  def from_beginning_of_day?
    starts_at - starts_at.beginning_of_day < machine.min_duration 
  end

  def leaves_time_till?(booking)
    return true if booking.nil?
    booking.starts_at - ends_at >= machine.min_duration
  end

  def starts_long_after?(booking)
    return true if booking.nil?
    starts_at - booking.ends_at >= machine.min_duration
  end

  def self.next(machine_id, after, before = nil)
    rel = Booking.where(:machine_id => machine_id).where("starts_at >= :time", :time => after)
    rel = rel.where("starts_at < :time2", :time2 => before) if before
    rel.order(:starts_at).first
  end

  def next
    Booking.next(machine_id, ends_at)
  end

  def prev
    Booking.where(:machine_id => machine_id).
      where("ends_at <= :time", :time => starts_at).
      order(:starts_at).
      last
  end

  def book_after_ok?
    leaves_time_till?(self.next) && !till_end_of_day?
  end

  def book_before_ok?
    starts_long_after?(self.prev) && !from_beginning_of_day?
  end

  def group_errors(group)
    value = []
    value << errors[:base].collect{|e| e if e.match(/#{group.name}/)}
    group.options.each do |opt|
      value << errors[:base].collect{|e| e if e.match(/#{opt.name}/)}
    end
    value.flatten.compact
  end

  def needed
    options.collect{|o| o.needed}.flatten.compact
  end

  def time_range
    starts_at...ends_at
  end

  def overlaps?(other)
    !overlap(other).blank?
  end

  def overlap(other)
    time_range.overlap(other)
  end

  def not_available_options
    res = machine.options.map{|o| o.id unless o.available?(self)}.compact
    options.each do |opt|
      res << opt.excluded_options.map{|o| o.id}
    end
    return res.flatten.uniq
  end

  def same_time_bookings
    rel = Booking.during(self)
    rel = rel.where("id != :id", :id => id) unless self.new_record?
    rel
  end

  def self.during(obj)
    if obj.is_a?(Booking)
      start, stop = obj.starts_at, obj.ends_at
    else
      start, stop = obj.begin, obj.end
    end

    rel = Booking.where( "(starts_at <= :start and ends_at > :start) OR (starts_at < :end and ends_at > :end) OR (starts_at >= :start and ends_at <= :end)", :start => start, :end => stop)
    rel = rel.order(:starts_at)
    rel
  end

  def to_ics
    event = Icalendar::Event.new
    if all_day?
      event.start = starts_at.to_date
      event.end = ends_at.to_date
      event.start.ical_params = { "VALUE" => "DATE" }
      event.end.ical_params = { "VALUE" => "DATE" }
    else
      event.start = I18n.l(starts_at, format: :ical)
      event.end = I18n.l(ends_at, format: :ical)
    end
    event.summary = ics_title
    event.description = ics_description
    event.location = 'Uni'
    event.klass = "PUBLIC"
    event.created = I18n.l(created_at, format: :ical)
    event.last_modified = I18n.l(updated_at, format: :ical)
    event.uid = "timit_booking_#{self.id}"
    event.url = "http://timit.chemie.uni-freiburg.de/#{I18n.locale}/calendar"
    event
  end

  def ics_title
    I18n.t('ics.measurement', machine: machine.name)
  end

  def ics_description
    desc = []
    desc << "#{Booking.model_name.human} #{id}"
    desc << "#{Booking.human_attribute_name(:sample)}: #{sample}" unless sample.blank?
    desc << "#{Booking.human_attribute_name(:temperature)}: #{temperature}" unless temperature.blank?
    desc << "#{Booking.human_attribute_name(:options)}: #{options.map(&:name).join(', ')}" if options.any?
    desc.join("\n")
  end

  #TODO: SPEC
  def self.in_future(machine, user)
    Booking.where(:user_id => user.id).where(:machine_id => machine.id).where("starts_at >= :now", :now => DateTime.now) 
  end

  def last_minute?
    if starts_at.present? && starts_at.to_date - Time.now.to_date <=1 && maximum_exceeded?
      true
    else
      false
    end
  end

  def maximum_exceeded?
    return false if Ability.new(user).can? :exceed_maximum, Booking
    Booking.in_future(machine, user).size >= machine.max_future_bookings
  end

  private
  def end_after_start
    errors.add(:ends_at, :start_after_end) unless ends_at && starts_at && ends_at > starts_at
  end

  def no_overlaps
    same_time_bookings.where(:machine_id => machine_id).each do |conflict|
      attribute = overlap(conflict).cover?(starts_at) ? :starts_at : :ends_at
      errors.add(attribute, :date_conflicts, :from => conflict.human_start, :to => conflict.human_end)
    end
  end

  def needed_accessories_available
    options.each do |opt|
      opt.available?(self, return_conflicts = true).each do |conflict|
        errors.add(:base, :accessory_conflict, :name => opt.name, :from => I18n.l(conflict.begin), :to => I18n.l(conflict.end) )
      end
    end
  end

  def not_to_long
    if machine && machine.max_duration_for(user)
      duration = ends_at - starts_at
      text = user.role?('teaching') ? I18n.t('human_time_units.hour', :count => 6) : I18n.t('human_time_units.' + machine.max_duration_unit, :count => machine.max_duration)
      max = last_minute? ? [2.days, machine.max_duration_for(user)].min : machine.max_duration_for(user)
      errors.add(:ends_at, :to_long, :max => text) if duration > max
    end
  end

  def not_to_short
    if machine && ends_at && starts_at
      duration = ends_at - starts_at
      text = I18n.t('human_time_units.' + machine.min_booking_time_unit, :count => machine.min_booking_time)
      errors.add(:ends_at, :to_short, :min => text) if duration < machine.min_duration
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

  def adjust_time_to_all_day
    if all_day
      self.starts_at = starts_at.beginning_of_day
      self.ends_at = ends_at.end_of_day
    end
  end

  def no_option_conflicts
    options.each do |opt|
      conflicts = (opt.excluded_options & options)
      conflicts.each do |conflict|
        errors.add(:base, :option_conflict, :name => opt.name, :with => conflict )
      end
    end
  end
end
