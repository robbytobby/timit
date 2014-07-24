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
  it { should have_and_belong_to_many(:options) }

  describe "validations" do
    it {should validate_numericality_of(:temperature), :integer_only => true }
    it {should validate_presence_of(:user_id)}
    it {should validate_numericality_of(:user_id), :integer_only => true }
    it {should validate_presence_of(:machine_id)}
    it {should validate_numericality_of(:machine_id), :integer_only => true}
    it {should validate_presence_of(:ends_at)}
    it {should validate_presence_of(:starts_at)}

    it "does not accept bookings exceeding the maximum duration" do
      @machine = FactoryGirl.create(:machine, :max_duration => 2, :max_duration_unit => 'day')
      @now = DateTime.now
      @booking = FactoryGirl.build(:booking, :machine => @machine, :starts_at => @now, :ends_at => @now + @machine.real_max_duration + 1.minute)
      @booking.should_not be_valid
    end
    
    it "does not accept bookings shorter than the minimum duration" do
      @machine = FactoryGirl.create(:machine, :min_booking_time => 2, :min_booking_time_unit => 'hour')
      @now = DateTime.now
      @booking = FactoryGirl.build(:booking, :machine => @machine, :starts_at => @now, :ends_at => @now + @machine.min_duration - 1.minutes)
      @booking.should_not be_valid
    end

    it {should_not accept_values_for(:ends_at, booking.starts_at - 1.minute, booking.starts_at - 1.day)}

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
          FactoryGirl.build(:booking, :starts_at => @now + 6.hours, :ends_at => @now + 7.hours, :machine => @old_booking.machine).should be_valid
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

    it "is not valid without temperature if machine needs temperature"  do
      @machine = FactoryGirl.create(:machine, :needs_temperature => true)
      @booking = FactoryGirl.build(:booking, :machine => @machine)
      @booking.should_not be_valid
    end

    it "is not valid without sample if machine needs sample" do
      @machine = FactoryGirl.create(:machine, :needs_sample => true)
      @booking = FactoryGirl.build(:booking, :machine => @machine)
      @booking.should_not be_valid
    end

    describe "booking options" do
      before :each do
        @machine = FactoryGirl.create(:machine)
        @groups = [
          @group1 = FactoryGirl.create(:option_group, :exclusive => true, :optional => true),
          @group2 = FactoryGirl.create(:option_group, :exclusive => true, :optional => false),
          @group3 = FactoryGirl.create(:option_group, :exclusive => false, :optional => true),
          @group4 = FactoryGirl.create(:option_group, :exclusive => false, :optional => false)
        ]
        
        @groups.each do |group|
          FactoryGirl.create_list(:option, 3, :option_group => group)
          group.options.each{|o| @machine.options << o}
        end
      end

      it "is not valid if no option in a non-optional group is checked" do
        @booking = FactoryGirl.build(:booking, :machine => @machine)
        @booking.should_not be_valid
        @groups.each do |group|
          @booking.group_errors(group).send(group.optional ? :should : :should_not, be_empty)
        end
      end

      it "is valid if one option of each non-optional group is checked" do
        @booking = FactoryGirl.build(:booking, :machine => @machine, :options => [@group2.options[0], @group4.options[0]])
        @booking.should be_valid
        @groups.each do |group|
          @booking.group_errors(group).should be_empty
        end
      end

      it "is valid if no more than one option of an exclusive group is given" do
        @booking = FactoryGirl.build(:booking, :machine => @machine, :options => [@group2.options[0], @group4.options[0], @group3.options].flatten)
        @booking.should be_valid
        @booking.group_errors(@group1).should be_empty
        @booking.group_errors(@group2).should be_empty
        @booking.group_errors(@group3).should be_empty
        @booking.group_errors(@group4).should be_empty
      end

      it "is not valid if more than one option of an non exclusive group is given" do
        @booking = FactoryGirl.build(:booking, :machine => @machine, :options => [@group2.options[0], @group4.options[0], @group1.options].flatten)
        @booking.should_not be_valid
        @booking.group_errors(@group1).should_not be_empty
        @booking.group_errors(@group2).should be_empty
        @booking.group_errors(@group3).should be_empty
        @booking.group_errors(@group4).should be_empty
      end

      describe "conflicting options" do
        before :each do
          @group5 = FactoryGirl.create(:option_group, :exclusive => true, :optional => true)
          @group6 = FactoryGirl.create(:option_group, :exclusive => true, :optional => true)
          @group7 = FactoryGirl.create(:option_group, :exclusive => true, :optional => true)
          @option1 = FactoryGirl.create(:option, :option_group => @group5)
          @option2 = FactoryGirl.create(:option, :option_group => @group6)
          @option3 = FactoryGirl.create(:option, :option_group => @group7, :excluded_options => [@option1, @option2])
          @machine2 = FactoryGirl.create(:machine, :options => [@option1, @option2, @option3])
        end

        it "is valid with one of two conflicting options #1" do
          @booking = FactoryGirl.build(:booking, :machine => @machine2, :options => [@option1])
          @booking.should be_valid
        end

        it "is valid with one of two conflicting options #2" do
          @booking = FactoryGirl.build(:booking, :machine => @machine2, :options => [@option2])
          @booking.should be_valid
        end

        it "is valid with two of the not conflicting options" do
          @booking = FactoryGirl.build(:booking, :machine => @machine2, :options => [@option1, @option2])
          @booking.should be_valid
        end

        it "is not valid with two of the conflicting options #2" do
          @booking = FactoryGirl.build(:booking, :machine => @machine2, :options => [@option1, @option3])
          @booking.should_not be_valid
        end

        it "is not valid with two of the conflicting options #3" do
          @booking = FactoryGirl.build(:booking, :machine => @machine2, :options => [@option2, @option3])
          @booking.should_not be_valid
        end
      end

      describe 'needed accessories' do
        before :each do
          @option_group = FactoryGirl.create(:option_group, :optional => true)
          @option1 = FactoryGirl.create(:option, :option_group => @option_group, :needed => [FactoryGirl.create(:accessory, :quantity => 1)] )
          @option2 = FactoryGirl.create(:option, :option_group => @option_group, :needed => [FactoryGirl.create(:accessory, :quantity => 2)] )
          @machine1 = FactoryGirl.create(:machine, :options => [@option1, @option2])
          @machine2 = FactoryGirl.create(:machine, :options => [@option1, @option2])
        end

        it "is valid if a needed accessory is available" do
          @booking = FactoryGirl.build(:booking, :machine => @machine1, :options => [@option1])
          @booking.should be_valid
        end

        it "is not valid if a needed accessory is not available" do
          @booking2 = FactoryGirl.create(:booking, machine: @machine2, options: [@option1], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking = FactoryGirl.build(:booking, machine: @machine1, options: [@option1], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking.should_not be_valid
        end

        it "is valid if a needed accessory is available mutliple times, but booked less times" do
          @booking2 = FactoryGirl.create(:booking, machine: @machine2, options: [@option2], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking = FactoryGirl.build(:booking, machine: @machine1, options: [@option2], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking.should be_valid
        end

        it "is not valid if a neede accessory is available n times and booked n times" do
          @machine3 = FactoryGirl.create(:machine, :options => [@option1, @option2])
          @booking3 = FactoryGirl.create(:booking, machine: @machine3, options: [@option2], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking2 = FactoryGirl.create(:booking, machine: @machine2, options: [@option2], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking = FactoryGirl.build(:booking, machine: @machine1, options: [@option2], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking.should_not be_valid
        end

        it "is  valid if a neede accessory is available n times, but not booked n times during the same period" do
          @machine3 = FactoryGirl.create(:machine, :options => [@option1, @option2])
          @booking3 = FactoryGirl.create(:booking, machine: @machine3, options: [@option2], starts_at: Time.now - 1.hour, ends_at: Time.now + 1.minute)
          @booking2 = FactoryGirl.create(:booking, machine: @machine2, options: [@option2], starts_at: Time.now + 2.minutes, ends_at: Time.now + 2.hour)
          @booking = FactoryGirl.build(:booking, machine: @machine1, options: [@option2], starts_at: Time.now, ends_at: Time.now + 1.hour)
          @booking.should be_valid
        end
      end
    end
  end

  describe "days" do
    it("is a Range") { booking.days.class.should == Range }
    it("the first is the start date") { booking.days.first.should == booking.starts_at.to_date }
    it("the last ist the ending date") { booking.days.last.should == booking.ends_at.to_date }
    ("2011-10-17".to_date.."2011-10-19".to_date).each{|d| it("includes #{d}") {should be_includes(d)} }
    it("do not include the day before") { should_not be_includes("2011-10-16".to_date) }
    it("do not include the day after") { should_not be_includes("2011-10-20".to_date) }
    it "do not include the end day if ends_at 00:00" do
      @booking = FactoryGirl.create(:booking, :starts_at => "2011-10-17 01:00:00", :ends_at => "2011-10-18 00:00:00" )
      @booking.days.cover?("2011-10-18".to_date).should be_false
      @booking.days.cover?("2011-10-17".to_date).should be_true
    end
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
      @booking1 = FactoryGirl.create(:booking, :starts_at => "2011-12-01 00:00:00", :ends_at => "2011-12-02 00:03:00")
      @booking2 = FactoryGirl.create(:booking, :starts_at => "2011-12-01 00:02:00", :ends_at => "2011-12-02 00:05:00")
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

  describe "not_available_options" do
    before :each do
      @option_group1 = FactoryGirl.create(:option_group, :optional => true)
      @option_group2 = FactoryGirl.create(:option_group, :optional => true)
      @option1 = FactoryGirl.create(:option, :option_group => @option_group1)
      @option2 = FactoryGirl.create(:option, :option_group => @option_group1)
      @option3 = FactoryGirl.create(:option, :option_group => @option_group2)
      @option4 = FactoryGirl.create(:option, :option_group => @option_group2)
      @machine1 = FactoryGirl.create(:machine, :options => [@option1, @option2, @option3, @option4])
    end

    it "returns an array of the non available options" do
      @option2.stub(:available? => false)
      @option4.stub(:available? => false)
      @booking = FactoryGirl.build(:booking, machine: @machine1)
      @booking.not_available_options.should == [@option2.id, @option4.id]
    end

    it "disables options excluded by others" do
      @option1.stub(:excluded_options => [@option3])
      @booking = FactoryGirl.build(:booking, machine: @machine1, options: [@option1, @option2])
      @booking.not_available_options.should == [@option3.id]
    end
  end

  describe "overlap" do
    before :each do
      @t = "2011-12-27 00:00:00".to_datetime
      @booking1 = FactoryGirl.build(:booking, starts_at: @t,           ends_at: @t + 12.hours)
      @booking2 = FactoryGirl.build(:booking, starts_at: @t - 6.hours, ends_at: @t + 6.hours)
      @booking3 = FactoryGirl.build(:booking, starts_at: @t + 3.hours, ends_at: @t + 9.hours)
      @booking4 = FactoryGirl.build(:booking, starts_at: @t - 3.hours, ends_at: @t + 15.hours)
      @booking5 = FactoryGirl.build(:booking, starts_at: @t + 6.hours, ends_at: @t + 15.hours)
      @booking6 = FactoryGirl.build(:booking, starts_at: @t - 2.days,  ends_at: @t - 1.day)
      @booking7 = FactoryGirl.build(:booking, starts_at: @t + 2.days,  ends_at: @t + 3.days)
    end

    describe "returns the overlapping time with another Booking" do
      it("example 1"){ @booking1.overlap(@booking2).should == (@t...(@t + 6.hours)) }
      it("example 2"){ @booking2.overlap(@booking1).should == (@t...(@t + 6.hours)) }
      it("example 3"){ @booking1.overlap(@booking3).should == ((@t + 3.hours)...(@t + 9.hours)) }
      it("example 4"){ @booking3.overlap(@booking1).should == ((@t + 3.hours)...(@t + 9.hours)) }
      it("example 5"){ @booking1.overlap(@booking4).should == ((@t + 0.hours)...(@t + 12.hours)) }
      it("example 6"){ @booking4.overlap(@booking1).should == ((@t + 0.hours)...(@t + 12.hours)) }
      it("example 7"){ @booking1.overlap(@booking5).should == ((@t + 6.hours)...(@t + 12.hours)) }
      it("example 8"){ @booking5.overlap(@booking1).should == ((@t + 6.hours)...(@t + 12.hours)) }
      it("example 9"){ @booking1.overlap(@booking6).should == nil }
      it("example 10"){ @booking6.overlap(@booking1).should == nil }
      it("example 11"){ @booking1.overlap(@booking7).should == nil }
      it("example 12"){ @booking7.overlap(@booking1).should == nil }
      it("example 13"){ @booking2.overlap(@booking5).should == nil }
    end

    describe "returns the overlapping time with a Range" do
      it("example 1"){ @booking1.overlap((@t - 1.day)...@t).should == nil}
      it("example 2"){ @booking1.overlap((@t - 1.hour)...(@t + 2.hours)).should == (@t...(@t + 2.hours)) }
      it("example 3"){ @booking1.overlap((@t + 1.hour)...(@t + 3.hours)).should == ((@t + 1.hour)...(@t + 3.hours)) }
      it("example 4"){ @booking1.overlap((@t + 4.hour)...(@t + 20.hours)).should == ((@t + 4.hours)...(@t + 12.hours)) }
      it("example 5"){ @booking1.overlap((@t - 1.hour)...(@t + 22.hours)).should == (@t...(@t + 12.hours)) }
    end

    describe "handels overlap with multiple bookings" do
      it("example 1"){ @booking1.overlap([@booking2, @booking3]).should == {
        0 => [@booking1.time_range],
        1 => [@booking1.overlap(@booking2), @booking1.overlap(@booking3)],
        2 => [@booking1.overlap(@booking2.overlap(@booking3))] } }
      it("example 2"){ @booking1.overlap([@booking2, @booking3, @booking4]).should == {
        0 => [@booking1.time_range],
        1 => [@booking1.overlap(@booking2), @booking1.overlap(@booking3), @booking1.overlap(@booking4)],
        2 => [@booking1.overlap(@booking2.overlap(@booking3)), @booking1.overlap(@booking2.overlap(@booking4)), @booking1.overlap(@booking3.overlap(@booking4))],
        3 => [@booking1.overlap(@booking2.overlap((@booking3).overlap(@booking4)))]} }
      it("example 3"){ @booking1.overlap([@booking2, @booking3, @booking5, @booking6]).should == {
        0 => [@booking1.time_range], 
        1 => [@booking1.overlap(@booking2), @booking1.overlap(@booking3), @booking1.overlap(@booking5)],
        2 => [@booking1.overlap(@booking2.overlap(@booking3)), @booking1.overlap(@booking3.overlap(@booking5))]
         } }
      it("example 4"){ @booking1.overlap([@booking3, @booking5, @booking6, @booking7]).should == {
        0 => [@booking1.time_range], 
        1 => [@booking1.overlap(@booking3), @booking1.overlap(@booking5), @booking1.overlap(@booking6)].compact,
        2 => [@booking1.overlap(@booking3.overlap(@booking5)), @booking1.overlap(@booking3.overlap(@booking6)), @booking1.overlap(@booking5.overlap(@booking6))].compact
         } }
      it("example 6"){ @booking1.overlap([@booking2, @booking3, @booking4, @booking5, @booking6, @booking7]).should == {
        0 => [@booking1.time_range],
        1 => [@booking1.overlap(@booking2),
              @booking1.overlap(@booking3), 
              @booking1.overlap(@booking4), 
              @booking1.overlap(@booking5), 
              @booking1.overlap(@booking6), 
              @booking1.overlap(@booking7)].compact,
        2 => [@booking1.overlap(@booking2.overlap(@booking3)), 
              @booking1.overlap(@booking2.overlap(@booking4)), 
              @booking1.overlap(@booking2.overlap(@booking5)), 
              @booking1.overlap(@booking2.overlap(@booking6)), 
              @booking1.overlap(@booking2.overlap(@booking7)), 
              @booking1.overlap(@booking3.overlap(@booking4)), 
              @booking1.overlap(@booking3.overlap(@booking5)), 
              @booking1.overlap(@booking3.overlap(@booking6)), 
              @booking1.overlap(@booking3.overlap(@booking7)),
              @booking1.overlap(@booking4.overlap(@booking5)), 
              @booking1.overlap(@booking4.overlap(@booking6)), 
              @booking1.overlap(@booking4.overlap(@booking7)),
              @booking1.overlap(@booking5.overlap(@booking6)), 
              @booking1.overlap(@booking5.overlap(@booking7)),
              @booking1.overlap(@booking6.overlap(@booking7))].compact,
        3 => [@booking1.overlap(@booking2.overlap((@booking3).overlap(@booking4))),
              @booking1.overlap(@booking2.overlap((@booking3).overlap(@booking5))),
              @booking1.overlap(@booking2.overlap((@booking3).overlap(@booking6))),
              @booking1.overlap(@booking2.overlap((@booking3).overlap(@booking7))),
              @booking1.overlap(@booking3.overlap((@booking4).overlap(@booking5))),
              @booking1.overlap(@booking3.overlap((@booking4).overlap(@booking6))),
              @booking1.overlap(@booking3.overlap((@booking4).overlap(@booking7))),
              @booking1.overlap(@booking4.overlap((@booking5).overlap(@booking6))),
              @booking1.overlap(@booking4.overlap((@booking5).overlap(@booking7))),
              @booking1.overlap(@booking5.overlap((@booking6).overlap(@booking7))),
              ].compact
        } }

    end
  end

  describe "to_ics" do
    before(:each) { @booking = FactoryGirl.create(:booking) }

    it "should be a Icalendar event" do
      @booking.to_ics.should be_a(Icalendar::Event)
    end

    it "has the correct data" do
      Booking.any_instance.stub(ics_title: 'TITLE', ics_description: 'DESCRIPTION')
      event = @booking.to_ics
      event.start.should == I18n.l(@booking.starts_at, format: :ical)
      event.end.should == I18n.l(@booking.ends_at, format: :ical)
      event.summary.should == 'TITLE'
      event.description.should == 'DESCRIPTION'
      event.location.should == 'Uni'
      event.klass.should == 'PUBLIC'
      event.created.should == I18n.l(@booking.created_at, format: :ical)
      event.last_modified.should == I18n.l(@booking.updated_at, format: :ical)
      event.uid.should == "timit_booking_#{@booking.id}"
      event.url.should == "http://timit.chemie.uni-freiburg.de/#{I18n.locale}/calendar"
    end

    it "deals with all_day_events" do
      @booking.all_day = true
      event = @booking.to_ics
      event.start.should == @booking.starts_at.to_date
      event.start.ical_params.should == {"VALUE" => "DATE"}
      event.end.should == @booking.ends_at.to_date + 1.day
      event.end.ical_params.should == {"VALUE" => "DATE"}
    end
  end

  describe "ics_title" do
    before(:each) { @booking = FactoryGirl.create(:booking) }
    it "should be coreect" do
      @booking.ics_title.should == I18n.t('ics.measurement', machine: @booking.machine.name)
    end
  end

  describe "ics_description" do

    it "should include the booking id" do
      @booking = FactoryGirl.create(:booking)
      @booking.ics_description.should match(/Buchung #{@booking.id}/)
    end

    it "should include the sample if it is given" do
      @booking = FactoryGirl.create(:booking, sample: 'MySample')
      @booking.ics_description.should match(/Probe: #{@booking.sample}/)
    end

    it "should not include the sample if it is not given" do
      @booking = FactoryGirl.create(:booking, sample: nil)
      @booking.ics_description.should_not match(/Probe:/)
    end

    it "should include the temperature if it is given" do
      @booking = FactoryGirl.create(:booking, temperature: 100)
      @booking.ics_description.should match(/Temperatur \[K\]: #{@booking.temperature}/)
    end

    it "should not include the temperature if it is not given" do
      @booking = FactoryGirl.create(:booking, temperature: nil)
      @booking.ics_description.should_not match(/Temperatur \[K\]:/)
    end


    it "should include the options" do
      @booking = FactoryGirl.create(:booking)
      @options = FactoryGirl.create_list(:option,3)
      @booking.stub(options: @options)
      @booking.ics_description.should match(/Optionen: #{@options.map(&:name).join(', ')}/)
    end

    it "should not include the options if there are none" do
      @booking = FactoryGirl.create(:booking)
      @booking.ics_description.should_not match(/Probe:/)
    end
  end

  describe "last_minute?", focus: true do
    it "is true if user allready has max of bookings in future, for a new booking wich starts today or tomorrow" do
      @machine = FactoryGirl.create(:machine, max_future_bookings: 1)
      @user = FactoryGirl.create(:user)
      @old_booking = FactoryGirl.create(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.month, ends_at: Time.now + 1.month + 1.day)
      @booking = FactoryGirl.build(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.day, ends_at: Time.now + 2.days)
      @booking.should be_last_minute
    end
    
    it "is false if a user does not exceed it's maximum" do
      @booking = FactoryGirl.build(:booking, starts_at: Time.now + 1.day, ends_at: Time.now + 2.days)
      @booking.should_not be_last_minute
    end

    it "is false for a booking that starts later than tomorrow" do
      @booking = FactoryGirl.build(:booking, starts_at: Time.now + 2.days, ends_at: Time.now + 4.days)
      @booking.should_not be_last_minute
    end

    it "is false for an admin" do
      @machine = FactoryGirl.create(:machine, max_future_bookings: 1)
      @user = FactoryGirl.create(:admin_user)
      @old_booking = FactoryGirl.create(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.month, ends_at: Time.now + 1.month + 1.day)
      @booking = FactoryGirl.build(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.day, ends_at: Time.now + 2.days)
      @booking.should_not be_last_minute
    end

    it "is false for a teacher" do
      @machine = FactoryGirl.create(:machine, max_future_bookings: 1)
      @user = FactoryGirl.create(:teaching_user)
      @old_booking = FactoryGirl.create(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.month, ends_at: Time.now + 1.month + 2.hours)
      @booking = FactoryGirl.build(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.day, ends_at: Time.now + 2.days)
      @booking.should_not be_last_minute
    end
  end

  describe "last minute bookings", focus: true do
    it "is valid if booking duration is less than two days" do
      @machine = FactoryGirl.create(:machine, max_future_bookings: 1, max_duration: 7, max_duration_unit: 'day')
      @user = FactoryGirl.create(:user)
      @old_booking = FactoryGirl.create(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.month, ends_at: Time.now + 1.month + 1.day)
      @booking = FactoryGirl.build(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.day, ends_at: Time.now + 2.days)
      @booking.should be_valid
    end

    it "is not valid if booking duration is more than two days" do
      @machine = FactoryGirl.create(:machine, max_future_bookings: 1, max_duration: 7, max_duration_unit: 'day')
      @user = FactoryGirl.create(:user)
      @old_booking = FactoryGirl.create(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.month, ends_at: Time.now + 1.month + 1.day)
      @booking = FactoryGirl.build(:booking, machine: @machine, user: @user, starts_at: Time.now, ends_at: Time.now + 2.days + 1.hour)
      @booking.should_not be_valid
    end

    it "respects the maximum booking duration for a machine" do
      @machine = FactoryGirl.create(:machine, max_future_bookings: 1, max_duration: 1, max_duration_unit: 'day')
      @user = FactoryGirl.create(:user)
      @old_booking = FactoryGirl.create(:booking, machine: @machine, user: @user, starts_at: Time.now + 1.month, ends_at: Time.now + 1.month + 3.hours)
      @booking = FactoryGirl.build(:booking, machine: @machine, user: @user, starts_at: Time.now, ends_at: Time.now + 1.days + 1.hour)
      @booking.should_not be_valid
    end
  end
end
