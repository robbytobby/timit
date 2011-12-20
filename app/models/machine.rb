class Machine < ActiveRecord::Base
  @@time_units = [:week, :day, :hour, :minute]
  strip_attributes
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :max_duration_unit, :presence => {:if => :unit_required?}
  validates_inclusion_of :max_duration_unit, :in => @@time_units.map{|u| u.to_s}, :allow_nil => true
  has_many :bookings, :dependent => :destroy
  has_many :options, :dependent => :destroy
  has_many :option_groups, :through => :options
  accepts_nested_attributes_for :options, :reject_if => :all_blank

  def self.time_units
    @@time_units
  end

  def real_max_duration
    max_duration.send(max_duration_unit) if max_duration
  end

  def human_max_duration
    if max_duration
      I18n.t("human_time_units.#{max_duration_unit}", :count => max_duration)
    else
      I18n.t("time_units.unlimited")
    end
  end

  protected
  def unit_required?
    max_duration != nil
  end
end
