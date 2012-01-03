class Accessory < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :quantity
  validates_uniqueness_of :name, :allow_blank => true
  has_and_belongs_to_many :options
end
