require 'spec_helper'
require 'cancan/matchers'

describe Booking do
  before :each do
    @booking = FactoryGirl.build(:booking)
  end

  it "should be valid" do
    @booking.should be_valid
  end

  it "includes all days between the starting and the ending day" do
    @booking = FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14")
    @booking.days.each{|d| @booking.includes?(d).should be_true}
    @booking.includes?(@booking.days.first - 1.day).should be false
    @booking.includes?(@booking.days.last + 1.day).should be false
  end

  it "knows its first and last day" do
    @booking = FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14")
    @booking.first_day?("2011-10-17".to_date).should be_true
    @booking.first_day?("2011-10-18".to_date).should be_false
    @booking.first_day?("2011-10-19".to_date).should be_false
    @booking.last_day?("2011-10-17".to_date).should be_false
    @booking.last_day?("2011-10-18".to_date).should be_false
    @booking.last_day?("2011-10-19".to_date).should be_true
  end

  it "is classified multiday if it spans more than one day" do
    @booking = FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14")
    @booking2 = FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-17 17:34:14")
    @booking.should be_multiday
    @booking2.should_not be_multiday
  end

  it "knows it's number of days" do
    FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-17 17:34:14").number_of_days.should == 1
    FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-18 17:34:14").number_of_days.should == 2
    FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14").number_of_days.should == 3
  end

  it "has a range of days" do
    @booking = FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14")
    @booking.days.class.should == Range
    @booking.days.first.should == @booking.starts_at.to_date
    @booking.days.last.should == @booking.ends_at.to_date
  end

  it "localizes starts_at" do
    @booking.human_start.should == I18n.l(@booking.starts_at, :format => :short)
    @booking.human_start(:long).should == I18n.l(@booking.starts_at, :format => :long)
  end

  it "localizes starts_at" do
    @booking.human_end.should == I18n.l(@booking.ends_at, :format => :short)
    @booking.human_end(:long).should == I18n.l(@booking.ends_at, :format => :long)
  end

  it "is not valid without user_id" do
    @booking.user_id = nil
    @booking.should_not be_valid
  end

  it "is not valid without machine_id" do
    @booking.machine_id = nil
    @booking.should_not be_valid
  end

  it "is not valid with end_at < starts_at" do
    @booking.ends_at = @booking.starts_at - 1.day
    @booking.should_not be_valid
  end

  describe "does not overlap" do
    before :each do
      @now = Time.now
      @old_booking = FactoryGirl.create(:booking, :starts_at => @now, :ends_at => @now + 6.hours)
    end
    
    describe "#new booking" do
      it "is not valid if its start lies in an existing booking for that machine" do
        FactoryGirl.build(:booking, :starts_at => @now, :ends_at => @now + 3.days).should be_valid
        FactoryGirl.build(:booking, :starts_at => @now, :ends_at => @now + 3.days, :machine_id => @old_booking.machine_id).should_not be_valid
      end

      it "is not valid if its end lies in an existing booking for that machine" do
        FactoryGirl.build(:booking, :starts_at => @now - 1.day, :ends_at => @now).should be_valid
        FactoryGirl.build(:booking, :starts_at => @now - 1.day, :ends_at => @now + 1.minute, :machine_id => @old_booking.machine_id).should_not be_valid
      end

      it "is not valid if its dates include an existing booking for that machine" do
        FactoryGirl.build(:booking, :starts_at => @now - 1.day, :ends_at => @now + 1.day).should be_valid
        FactoryGirl.build(:booking, :starts_at => @now - 1.day, :ends_at => @now + 1.day, :machine_id => @old_booking.machine_id).should_not be_valid
      end
    end

    describe "#existing booking" do
      before :each do
        @booking = FactoryGirl.create(:booking, :starts_at => @now + 7.hours, :ends_at => @now + 8.hours, :machine_id => @old_booking.machine_id)
      end

      it "is not valid if its start lies in an existing booking for that machine" do
        @booking.starts_at = @now + 6.hours 
        @booking.should be_valid

        @booking.starts_at = @now + 5.hours 
        @booking.should_not be_valid
      end

      it "#is not valid if its end lies in an existing booking for that machine" do
        @booking.starts_at = @now - 1.hour 
        @booking.ends_at = @now 
        @booking.should be_valid

        @booking.ends_at = @now + 1.hour
        @booking.should_not be_valid
      end

      it "#is not valid if its dates include an existing booking for that machine" do
        @booking.starts_at = @now - 1.hour 
        @booking.ends_at = @now 
        @booking.should be_valid

        @booking.ends_at = @now + 7.hours
        @booking.should_not be_valid
      end
    end
  end

  describe "permissions" do
    context "an unpriviliged user" do
      before :each do
        @user = FactoryGirl.create(:unprivileged_user) 
        @own_booking = FactoryGirl.create(:booking, :user => @user)
        @others_booking = FactoryGirl.create(:booking)
        @ability = Ability.new(@user)
      end

      subject{ @ability}
      it{ should_not be_able_to :manage, Booking}
      it{ should be_able_to :read, Booking }
      it{ should be_able_to :create, FactoryGirl.build(:booking, :user => @user) }
      it{ should be_able_to :edit, @own_booking }
      it{ should be_able_to :destroy, @own_booking }
      it{ should_not be_able_to :create, FactoryGirl.build(:booking) }
      it{ should_not be_able_to :edit, @others_booking }
      it{ should_not be_able_to :destroy, @others_booking }
    end

    context "a teaching user" do
      subject{ Ability.new(FactoryGirl.create(:teaching_user)) }
      it{ should be_able_to :manage, Booking}
    end

    context "an admin user" do
      subject{ Ability.new(FactoryGirl.create(:admin_user)) }
      it{ should be_able_to :manage, Booking}
    end
  end
end
