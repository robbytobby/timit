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

  def available?(obj, return_conflicts = false)
    raise "Either a booking or a time-range has to be given to Option#available? " unless obj.is_a?(Booking) || obj.is_a?(Range)
    conflicts = []

    bookings = obj.is_a?(Booking) ? obj.same_time_bookings : Booking.during(obj)
    needed.each do |n| 
      overlaps = obj.overlap(bookings.collect{|b| b if b.needed.include?(n)}.compact)
      if overlaps && overlaps[n.quantity]
        return false unless return_conflicts
        conflicts << overlaps[n.quantity]
      end
    end if bookings.any?

    return true unless return_conflicts
    conflicts.flatten.uniq
  end
end
