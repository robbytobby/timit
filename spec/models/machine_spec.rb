require 'spec_helper'

describe Machine do
  before(:each){FactoryGirl.create(:machine)}

  it {should have_many(:bookings).dependent(:destroy)}

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
    it {should strip_attributes([:name, :description])}

    it "is valid if it has a maximum duration and unit" do
      @machine = FactoryGirl.create(:machine, :max_duration => 3, :max_duration_unit => 'day')
      @machine.should be_valid
    end
    
    it "is not valid if it has a maximum duration, but no unit" do
      @machine = FactoryGirl.build(:machine, :max_duration => 3)
      @machine.should_not be_valid
    end

    it {should_not accept_values_for(:max_duration_unit, 'bla', 'second')}
    it {should accept_values_for(:max_duration_unit, 'day', 'hour', 'minute', 'week')}
  end

  describe "real_max_duration" do
    it "returns nil if max_duration is not set" do
      @machine = FactoryGirl.create(:machine)
      @machine.real_max_duration.should be_nil
    end

    Machine.time_units.each do |unit|
      it "returns the real value" do
        @machine = FactoryGirl.create(:machine, :max_duration => 6 , :max_duration_unit => unit.to_s)
        @machine.real_max_duration.should == 6.send(unit)
      end
    end

  end


end
