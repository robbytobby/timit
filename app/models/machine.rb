class Machine < ActiveRecord::Base
  strip_attributes
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :bookings, :dependent => :destroy

  def max_duration
    1.week
  end
end
