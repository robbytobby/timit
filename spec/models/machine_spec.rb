require 'spec_helper'

describe Machine do
  before(:each){FactoryGirl.create(:machine)}

  it {should have_many(:bookings).dependent(:destroy)}
  it {should have_and_belong_to_many(:options)}
  it {should have_many(:option_groups).through(:options)}

  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
    it {should strip_attributes([:name, :description])}
    it {should validate_numericality_of(:max_duration)}
    it {should validate_numericality_of(:min_booking_time)}
    it {should validate_numericality_of(:max_future_bookings)}

    it "should not be valid" do
      FactoryGirl.build(:machine, :name => '').should_not be_valid
    end

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

    it "is valid if it has a minimum duration and unit" do
      @machine = FactoryGirl.create(:machine, :min_booking_time => 3, :min_booking_time_unit => 'day')
      @machine.should be_valid
    end
    
    it "is not valid if it has a minimum duration, but no unit" do
      @machine = FactoryGirl.build(:machine, :min_booking_time => 3, :min_booking_time_unit => nil)
      @machine.should_not be_valid
    end

    it {should_not accept_values_for(:min_booking_time_unit, 'bla', 'second')}
    it {should accept_values_for(:min_booking_time_unit, 'day', 'hour', 'minute', 'week')}
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

  describe "human_max_duration" do
    it "returns unlimited if max_duration is not set" do
      @machine = FactoryGirl.create(:machine)
      @machine.human_max_duration.should == I18n.t('time_units.unlimited')
    end

    Machine.time_units.each do |unit|
      it "returns a combined value: duration + unit" do
        @machine = FactoryGirl.create(:machine, :max_duration => 6 , :max_duration_unit => unit.to_s)
        @machine.human_max_duration.should == I18n.t("human_time_units.#{@machine.max_duration_unit}", :count => @machine.max_duration)
      end
    end
  end

  describe "min_duration" do
    it "returns the minimum duration if it number and unit are given" do
      @machine = FactoryGirl.create(:machine, :min_booking_time => 20, :min_booking_time_unit => 'minute')
      @machine.min_duration.should == 20.minutes
    end

    it "returns one minute if no min booking time is set" do
      @machine = FactoryGirl.create(:machine, :min_booking_time => nil)
      @machine.min_duration.should == 1.minute
    end
  end

  describe "human_min_duration" do
    it "returns the minimum duration if set" do
      @machine = FactoryGirl.create(:machine, :min_booking_time => 20, :min_booking_time_unit => 'minute')
      @machine.human_min_duration.should == "20 Minuten"
    end

    it "returns unlimited if minimum duration is not set" do
      @machine = FactoryGirl.create(:machine, :min_booking_time => nil)
      @machine.human_min_duration.should == 'unbegrenzt'
    end
  end
end
