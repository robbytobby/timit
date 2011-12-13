class Machine < ActiveRecord::Base
  @@time_units = [:week, :day, :hour, :minute]
  strip_attributes
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :max_duration_unit, :presence => {:if => :unit_required?}
  validates_inclusion_of :max_duration_unit, :in => @@time_units.map{|u| u.to_s}, :allow_nil => true
  has_many :bookings, :dependent => :destroy

  def self.time_units
    @@time_units
  end

  def real_max_duration
    max_duration.send(max_duration_unit) if max_duration
  end

  protected
  def unit_required?
    max_duration != nil
  end
end
