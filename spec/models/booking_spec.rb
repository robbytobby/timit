require 'spec_helper'
require 'cancan/matchers'

describe Booking do

  let(:one_day_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-17 17:34:14")}
  let(:all_day_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14", :all_day => true)}
  let(:two_day_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-18 17:34:14")}
  let(:three_day_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14")}
  let(:from_midnight_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 00:59:00", :ends_at =>"2011-10-18 22:59:00")}
  let(:till_midnight_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 01:00:00", :ends_at =>"2011-10-18 23:01:00")}
  let(:from_and_till_midnight_booking){FactoryGirl.build(:booking, :starts_at => "2011-10-17 00:59:00", :ends_at =>"2011-10-18 23:01:00")}
  let(:booking){three_day_booking}
  subject{booking}

  it { should be_valid }
  it { should belong_to(:user) }
  it { should belong_to(:machine) }

  describe "days" do
    it("is a Range") { booking.days.class.should == Range }
    it("the first is the start date") { booking.days.first.should == booking.starts_at.to_date }
    it("the last ist the ending date") { booking.days.last.should == booking.ends_at.to_date }
    ("2011-10-17".to_date.."2011-10-19".to_date).each{|d| it("includes #{d}") {should be_includes(d)} }
    it("do not include the day before") { should_not be_includes("2011-10-16".to_date) }
    it("do not include the day after") { should_not be_includes("2011-10-20".to_date) }
  end

  describe "first_day?" do
    it { should be_first_day("2011-10-17".to_date) }
    it { should_not be_first_day("2011-10-18".to_date) }
    it { should_not be_first_day("2011-10-19".to_date) }
  end

  describe "last_day?" do
    it { should be_last_day("2011-10-19".to_date) }
    it { should_not be_last_day("2011-10-17".to_date) }
    it { should_not be_last_day("2011-10-18".to_date) }
  end

  describe "multiday?" do
    it("a three day booking is multiday") { should be_multiday }
    it("a one day booking is not multiday") { one_day_booking.should_not be_multiday }
  end

  describe "allday?" do
    it("is true if booking.all_day == true") { all_day_booking.should be_all_day }
    it("is false if booking only starts from midnight") { from_midnight_booking.should_not be_all_day }
    it("is false if booking only ends at midnight") { till_midnight_booking.should_not be_all_day }
    it("is true if booking starts and ends at midnight") { from_and_till_midnight_booking.should be_all_day }
  end

  describe "number_of_days" do
    it('is 1 for a one day booking') { one_day_booking.number_of_days.should == 1 }
    it('is 2 for a two days booking') { two_day_booking.number_of_days.should == 2 }
    it('is 3 for a three days booking') { three_day_booking.number_of_days.should == 3 }
  end

  describe "human_start and human end" do
    context "shows datetime if booking is not all day" do
      context "default format" do
        it { subject.human_start.should == I18n.l(booking.starts_at, :format => :default) }
        it { subject.human_end.should == I18n.l(booking.ends_at, :format => :default) }
      end
      context "long format" do
        it { subject.human_start(:long).should == I18n.l(booking.starts_at, :format => :long) }
        it { subject.human_end(:long).should == I18n.l(booking.ends_at, :format => :long) }
      end
    end
    
    context "shows date if booking is all day " do
      subject{all_day_booking}
      context "default format" do
        it { subject.human_start.should == I18n.l(all_day_booking.starts_at.to_date, :format => :default) }
        it { subject.human_end.should == I18n.l(all_day_booking.ends_at.to_date, :format => :default) }
      end
      context "long format" do
        it { subject.human_start(:long).should == I18n.l(all_day_booking.starts_at.to_date, :format => :long) }
        it { subject.human_end(:long).should == I18n.l(all_day_booking.ends_at.to_date, :format => :long) }
      end
    end
  end

  describe "next and previous booking" do
    before :each do
      @booking1 = FactoryGirl.create(:booking, :starts_at => "2011-12-01 00:00:00", :ends_at => "2011-12-01 00:02:00")
      @booking2 = FactoryGirl.create(:booking, :starts_at => "2011-12-01 00:02:00", :ends_at => "2011-12-01 00:05:00")
      @booking3 = FactoryGirl.create(:booking, :starts_at => "2011-12-03 00:02:02", :ends_at => "2011-12-04 00:03:00", :machine => @booking1.machine)
    end

    it("finds the next booking for that machine") { @booking1.next.should == @booking3 }
    it("finds the previous booking for that machine") { @booking3.prev.should == @booking1 }
    it("returns nil if there is no next booking") { @booking2.next.should be_nil }
    it("returns nil if there is no previous booking") { @booking2.prev.should be_nil }
  end

  describe "book_after_ok?" do
    it("is true if booking ends long before midnight") { should be_book_after_ok }
    it("is false if booking ends near midnight") { till_midnight_booking.should_not be_book_after_ok }
    it "is false, if time till next booking is less than one hour" do
      @booking = FactoryGirl.create(:booking, :starts_at => "2011-12-01 00:00:00", :ends_at => "2011-12-01 02:00:00")
      FactoryGirl.create(:booking, :starts_at => "2011-12-01 02:59:00", :ends_at => "2011-12-01 05:00:00", :machine => @booking.machine)
      @booking.should_not be_book_after_ok
    end
  end

  describe "book_before_ok?" do
    it("is true if booking starts long after midnight") { should be_book_before_ok }
    it("is false if booking starts near midnight") { from_midnight_booking.should_not be_book_before_ok}
    it "is false, if time after previous booking is less than one hour" do
      @booking = FactoryGirl.create(:booking, :starts_at => "2011-12-01 02:00:00", :ends_at => "2011-12-01 03:00:00")
      FactoryGirl.create(:booking, :starts_at => "2011-12-01 00:00:00", :ends_at => "2011-12-01 01:01:00", :machine => @booking.machine)
      @booking.should_not be_book_before_ok
    end
  end

  describe "validations" do
    it {should_not accept_values_for(:user_id, nil, 'ab', '', ' ')}
    it {should_not accept_values_for(:machine_id, nil, 'ab', '', ' ')}
    it {should_not accept_values_for(:ends_at, booking.starts_at - 1.minute, booking.starts_at - 1.day)}
    it "does not accept bookings exceeding the maximum" do
      @machine = FactoryGirl.create(:machine, :max_duration => 2, :max_duration_unit => 'day')
      @now = DateTime.now
      @booking = FactoryGirl.build(:booking, :machine => @machine, :starts_at => @now, :ends_at => @now + @machine.real_max_duration + 1.minute)
      @booking.should_not be_valid
    end

    describe "bookings may not overlap" do
      before :each do
        @now = Time.now.beginning_of_day
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

        it "is not valid if it is an all day booking and it dates include another booking" do
          FactoryGirl.build(:booking, :starts_at => @now + 6.hours, :ends_at => @now + 7.hours, :all_day => true).should be_valid
          FactoryGirl.build(:booking, :starts_at => @now + 6.hours, :ends_at => @now + 7.hours, :all_day => true, :machine => @old_booking.machine).should_not be_valid
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

        it "is not valid if its end lies in an existing booking for that machine" do
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

  it "has a maximum of bookings per day"
end
