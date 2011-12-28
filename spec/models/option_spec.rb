require 'spec_helper'

describe Option do
  before(:each){FactoryGirl.create(:option)}
  it{ should have_and_belong_to_many(:machines) }
  it{ should belong_to(:option_group) }
  it{ should have_and_belong_to_many(:bookings) }
  it{ should have_many(:needed) }
  it{ should validate_presence_of(:name)}
  it{ should validate_uniqueness_of(:name) }
  it{ should validate_presence_of(:option_group_id)}
end