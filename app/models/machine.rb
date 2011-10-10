class Machine < ActiveRecord::Base
  strip_attributes
  validates_presence_of :name
  validates_uniqueness_of :name
end
