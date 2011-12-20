require 'spec_helper'

describe Option do
  it{ should belong_to(:machine) }
  it{ should belong_to(:option_group) }
  it{ should validate_presence_of(:name)}
  it{ should validate_presence_of(:machine_id)}
  it{ should validate_presence_of(:option_group_id)}
end
