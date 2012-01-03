require 'spec_helper'

describe Option do
  before(:each){FactoryGirl.create(:option)}
  it{ should have_and_belong_to_many(:machines) }
  it{ should belong_to(:option_group) }
  it{ should have_and_belong_to_many(:bookings) }
  it{ should have_and_belong_to_many(:needed) }
  it{ should validate_presence_of(:name)}
  it{ should validate_uniqueness_of(:name) }
  it{ should validate_presence_of(:option_group_id)}

  describe "available" do
    describe "is not available for a specified time if needed accessories are not available" do
      before :each do
        @user = FactoryGirl.create(:approved_user)
        @acc1 = FactoryGirl.create(:accessory, :quantity => 1)
        @acc2 = FactoryGirl.create(:accessory, :quantity => 2)
        @opt_group = FactoryGirl.create(:option_group, :exclusive => false, :optional => true)
        @machine1 = FactoryGirl.create(:machine)
        @machine2 = FactoryGirl.create(:machine)
        @machine3 = FactoryGirl.create(:machine)
        @opt0 = FactoryGirl.create(:option, :option_group => @opt_group, :needed => [], :machines => [@machine1, @machine2, @machine3])
        @opt1 = FactoryGirl.create(:option, :option_group => @opt_group, :needed => [@acc1], :machines => [@machine1, @machine2, @machine3])
        @opt2 = FactoryGirl.create(:option, :option_group => @opt_group, :needed => [@acc2, @acc1], :machines => [@machine1, @machine2, @machine3])
        @opt3 = FactoryGirl.create(:option, :option_group => @opt_group, :needed => [@acc2], :machines => [@machine1, @machine2, @machine3])
        @now = Time.now
        @then = @now + 1.day
      end

      it "example 1" do
        @opt0.should be_available(@now...@then)
        @opt1.should be_available(@now...@then)
        @opt2.should be_available(@now...@then)
        @opt3.should be_available(@now...@then)
      end

      it "example 2" do
        @booking = FactoryGirl.create(:booking, :user => @user, :machine => @machine2, :options => [@opt1, @opt2], :starts_at => @now, :ends_at => @then)
        @opt0.should be_available(@now...@then)
        @opt1.should_not be_available(@now...@then)
        @opt2.should_not be_available(@now...@then)
        @opt3.should be_available(@now...@then)
      end

      it "example 3" do
        FactoryGirl.create(:booking, :user => @user, :machine => @machine2, :options => [@opt2], :starts_at => @now + 1.hour, :ends_at => @then - 12.hours)
        FactoryGirl.create(:booking, :user => @user, :machine => @machine3, :options => [@opt3], :starts_at => @then - 13.hours, :ends_at => @then + 12.hours)
        @opt0.should be_available(@now...@then)
        @opt1.should_not be_available(@now...@then)
        @opt2.should_not be_available(@now...@then)
        @opt3.should_not be_available(@now...@then)
      end

      it "example 4" do
        FactoryGirl.create(:booking, :user => @user, :machine => @machine2, :options => [@opt1], :starts_at => @now + 1.hour, :ends_at => @then - 12.hours)
        FactoryGirl.create(:booking, :user => @user, :machine => @machine3, :options => [@opt3], :starts_at => @then - 13.hours, :ends_at => @then + 12.hours)
        @opt0.should be_available(@now...@then)
        @opt1.should_not be_available(@now...@then)
        @opt2.should_not be_available(@now...@then)
        @opt3.should be_available(@now...@then)
      end

      it "example 5" do
        @booking = FactoryGirl.build(:booking, :machine => @machine1)
        @opt0.should be_available(@booking)
        @opt1.should be_available(@booking)
        @opt2.should be_available(@booking)
        @opt3.should be_available(@booking)
      end

      it "example 6" do
        FactoryGirl.create(:booking, :user => @user, :machine => @machine1, :options => [@opt1], :starts_at => @now + 1.hour, :ends_at => @now + 2.hours)
        FactoryGirl.create(:booking, :user => @user, :machine => @machine2, :options => [@opt2], :starts_at => @now + 2.hour, :ends_at => @now + 8.hours)
        FactoryGirl.create(:booking, :user => @user, :machine => @machine3, :options => [@opt3], :starts_at => @now + 6.hours, :ends_at => @then + 12.hours)
        @opt0.should be_available(@now...@then)
        @opt1.should_not be_available(@now...@then)
        @opt1.should_not be_available((@now+2.hours)..(@now + 9.hours))
        @opt1.should be_available((@now+8.hours)...@then)
        @opt2.should_not be_available(@now...@then)
        @opt2.should be_available(@now...(@now + 1.hours))
        @opt3.should be_available(@now...(@now + 6.hours))
        @opt3.should_not be_available(@now...(@now + 8.hours))
      end

      it "raises an error if neither booking nor range are given" do
        lambda{@opt1.available?('test')}.should raise_error
        lambda{@opt1.available?(@now...@then)}.should_not raise_error
        lambda{@opt1.available?(FactoryGirl.build(:booking))}.should_not raise_error
      end
    end
  end
end
