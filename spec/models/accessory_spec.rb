require 'spec_helper'

describe Accessory do
  before(:each){FactoryGirl.create(:accessory)}
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:quantity) }
  it { should belong_to(:option) }
end
