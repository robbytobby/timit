class OptionGroup < ActiveRecord::Base
  has_many :options, :dependent => :destroy, :order => :name
  validates_presence_of :name
  validates_inclusion_of :optional, :in => [true, false]
  validates_inclusion_of :exclusive, :in => [true, false]
end
