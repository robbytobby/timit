require 'spec_helper'

describe Machine do
  before(:each){FactoryGirl.create(:machine)}

  it {should have_many(:bookings).dependent(:destroy)}

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
    it {should strip_attributes([:name, :description])}
    it "should not be valid if it has a maximum duration, but no unit" do
      @machine = FactoryGirl.create(:machine)
      @machine.should be_valid
      @machine.max_duration = 3
      @machine.should_not be_valid
      @machine.max_duration_unit = 'day'
      @machine.should be_valid
    end
    it {should_not accept_values_for(:max_duration_unit, 'bla', 'second')}
    it {should accept_values_for(:max_duration_unit, 'day', 'hour', 'minute', 'week')}
  end


end
