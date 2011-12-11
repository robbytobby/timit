require 'spec_helper'

describe Machine do
  before(:all){FactoryGirl.create(:machine)}
  after(:all){Machine.destroy_all}

  it {should have_many(:bookings)}

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
    it {should strip_attributes([:name, :description])}
  end
end
