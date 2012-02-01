class OptionGroup < ActiveRecord::Base
  has_many :options, :dependent => :destroy, :order => :name
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :optional, :in => [true, false]
  validates_inclusion_of :exclusive, :in => [true, false]
  accepts_nested_attributes_for :options, :reject_if => :all_blank, :allow_destroy => true
end
