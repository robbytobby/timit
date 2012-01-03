class Option < ActiveRecord::Base
  belongs_to :option_group
  has_and_belongs_to_many :bookings
  has_and_belongs_to_many :machines
  has_and_belongs_to_many :needed, :class_name => 'Accessory', :order => :name
  validates_presence_of :name, :option_group_id
  validates_uniqueness_of :name

  def name
    read_attribute(:name).try(:html_safe)
  end

  def available?(during)
    return true if needed.empty?

    if during.is_a?(Booking)
      conflicts = during.same_time_bookings
    elsif during.is_a?(Range)
      conflicts = Booking.during(during)
    else
      raise "Either a booking or a time-range has to be given to Option#available? "
    end
    
    needed.each do |n| 
      testset = conflicts.collect{|b| b if b.needed.include?(n)}.compact
      #TODO overlaps für Ranges als basis
      booking = during.is_a?(Booking) ? during : Booking.new(:starts_at => during.begin, :ends_at => during.end)
      #TODO in overlap statt nil lehren hash zurückgeben
      overlaps = booking.overlap(testset)
      testset = overlaps[n.quantity] if overlaps
      return false if testset
    end if conflicts.any?
    return true
  end
end
