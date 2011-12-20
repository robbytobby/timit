class Option < ActiveRecord::Base
  belongs_to :machine
  belongs_to :option_group
  validates_presence_of :name, :machine_id, :option_group_id
end
