class Option < ActiveRecord::Base
  belongs_to :machine
  belongs_to :option_group
  has_and_belongs_to_many :bookings
  validates_presence_of :name, :machine_id, :option_group_id

  def name
    read_attribute(:name).try(:html_safe)
  end
end
