class Option < ActiveRecord::Base
  belongs_to :machine
  belongs_to :option_group
  has_and_belongs_to_many :bookings
  has_and_belongs_to_many :machines
  has_many :needed, :class_name => 'Accessory', :order => :name
  validates_presence_of :name, :option_group_id
  validates_uniqueness_of :name

  def name
    read_attribute(:name).try(:html_safe)
  end
end
