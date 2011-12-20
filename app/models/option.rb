class Option < ActiveRecord::Base
  belongs_to :machine
  validates_presence_of :name
end
