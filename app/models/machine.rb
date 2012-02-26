class Machine < ActiveRecord::Base
  @@time_units = [:week, :day, :hour, :minute]
  strip_attributes
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :max_duration_unit, :presence => {:if => lambda{|m| !m.max_duration.blank?} }
  validates :min_booking_time_unit, :presence => {:if => lambda{|m| !m.min_booking_time.blank?} }
  validates_inclusion_of :max_duration_unit, :in => @@time_units.map{|u| u.to_s}, :allow_nil => true
  validates_inclusion_of :min_booking_time_unit, :in => @@time_units.map{|u| u.to_s}, :allow_nil => true
  validates_numericality_of :max_duration, :only_integer => true, :allow_blank => true
  validates_numericality_of :min_booking_time, :only_integer => true, :allow_blank => true
  validates_numericality_of :max_future_bookings, :only_integer => true, :allow_blank => true
  has_many :bookings, :dependent => :destroy
  has_and_belongs_to_many :options, :order => :name
  has_and_belongs_to_many :users
  has_many :option_groups, :order => :name, :through => :options, :uniq => true

  def self.time_units
    @@time_units
  end

  #TODO Spec
  def real_max_duration
    max_duration.send(max_duration_unit) if max_duration
  end

  def max_duration_for(user = nil)
    if user.try(:role?, 'teaching') 
      return 6.hours
    else
      return real_max_duration
    end
  end
  
  def min_duration
    if min_booking_time
      min_booking_time.send(min_booking_time_unit) 
    else
      1.minute
    end
  end

  def human_min_duration
    if min_booking_time
      I18n.t("human_time_units.#{min_booking_time_unit}", :count => min_booking_time)
    else
      I18n.t("time_units.unlimited")
    end
  end

  def human_max_duration
    if max_duration
      I18n.t("human_time_units.#{max_duration_unit}", :count => max_duration)
    else
      I18n.t("time_units.unlimited")
    end
  end

end
