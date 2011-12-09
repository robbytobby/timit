require 'spec_helper'

describe Calendar do
  before :each do
    @calendar = Calendar.new
  end

  it "has the private methods :bookings=, :days=, :machines=" do
    [:bookings=, :days=, :machines=].each do |symbol|
      @calendar.private_methods.should include(symbol)
      @calendar.public_methods.should_not include(symbol)
    end
  end

  it "has the public methods :bookings, :days, :machines" do
    [:bookings, :days, :machines].each do |symbol|
      @calendar.private_methods.should_not include(symbol)
      @calendar.public_methods.should include(symbol)
    end
  end

  describe "initialization" do
    it "has today as defaults for start and end date" do
      @calendar.days.first.class.should == Date
      @calendar.days.last.class.should == Date
      @calendar.days.first.should < @calendar.days.last
    end

    it "may be set up for a given time span" do
      @calendar = Calendar.new(Date.today + 3.days, Date.today + 5.days)
      @calendar.days.first.should == Date.today + 3.days
      @calendar.days.last.should == Date.today + 5.days
    end

    describe "bookings" do
      before :all do
        @calendar = Calendar.new
        first_day = @calendar.days.first.to_datetime
        last_day = @calendar.days.last.to_datetime
        @to_early_booking = FactoryGirl.create(:booking, :starts_at => first_day - 1.day, :ends_at =>  first_day - 1.day + 1.second)
        @started_booking = FactoryGirl.create(:booking, :starts_at => first_day - 3.days, :ends_at =>  first_day)
        @today_booking = FactoryGirl.create(:booking, :starts_at => first_day, :ends_at => first_day + 1.second)
        @future_booking = FactoryGirl.create(:booking, :starts_at => last_day, :ends_at => last_day + 1.second)
        @future_booking2 = FactoryGirl.create(:booking, :starts_at => last_day - 2.days, :ends_at => last_day + 2.days)
        @to_late_booking = FactoryGirl.create(:booking, :starts_at => last_day + 1.day, :ends_at => last_day + 1.day + 1.second)
        @calendar = Calendar.new
      end

      after :all do
        Booking.destroy_all
        Machine.destroy_all
        User.destroy_all
      end

      it "is an array of bookings" do
        @calendar.bookings.all.should be_an(Array)
        @calendar.bookings.each{|b| b.should be_a(Booking)}
      end

      it "contains bookings with booking_start < calendar_end and Booking_end > calendar_start" do
        @calendar.bookings.should include(@today_booking, @future_booking)
      end

      it "contains bookings that are partially in the past" do
        @calendar.bookings.should include(@started_booking)
      end

      it "contains bookings that are partially in the future" do
        @calendar.bookings.should include(@future_booking2)
      end

      it "does not contain bookings entirely in the past" do
        @calendar.bookings.should_not include(@to_early_booking)
      end

      it "does not contain bookings entirely in the future" do
        @calendar.bookings.should_not include(@to_late_booking)
      end
    end

    describe "machines" do
      before :all do
        @machine1, @machine2, @machine3 = FactoryGirl.create_list(:machine, 3)
      end

      after :all do
        Machine.destroy_all
      end

      it "defaults to all machines" do
        @calendar = Calendar.new
        @calendar.machines.should include(@machine1, @machine2, @machine3)
      end

      it "may be restricted to selected machines" do
        @calendar = Calendar.new(nil, nil,[@machine1.id, @machine2.id])
        @calendar.machines.should include(@machine1, @machine2)
        @calendar.machines.should_not include(@machine3)
      end
    end
  end

  describe "new booking links" do
    before :all do
      @booking1 = FactoryGirl.create(:booking, :starts_at => '2011-12-08 02:00:00', :ends_at => '2011-12-09 11:00:00')
      @booking2 = FactoryGirl.create(:booking, :starts_at => '2011-12-08 02:00:00', :ends_at => '2011-12-09 11:00:00', :all_day => true)
      @booking3 = FactoryGirl.create(:booking, :starts_at => '2011-12-10 00:59:00', :ends_at => '2011-12-11 23:01:00')
      @booking4 = FactoryGirl.create(:booking, :starts_at => '2011-12-10 01:00:00', :ends_at => '2011-12-11 23:00:00')
      @calendar = Calendar.new('2011-12-01'.to_date)
    end

    after :all do
      Booking.destroy_all
      User.destroy_all
      Machine.destroy_all
    end

    describe "new booking links as first item" do
      it "does not have a new booking link in the beginning, if the first entry for a given date and machine starts in the past" do
        @calendar.draw_new_booking_first?(@booking1.machine_id, '2011-12-09'.to_date).should be_false
      end

      it "does not have a new booking link in the beginning, if the first entry for a given date and machine is an all day event" do
        @calendar.draw_new_booking_first?(@booking2.machine_id, '2011-12-08'.to_date).should be_false
      end

      it "does not have a new booking link in the beginning, if the free span in front is less than 1 hour" do
        @calendar.draw_new_booking_first?(@booking3.machine_id, '2011-12-10'.to_date).should be_false
      end

      it "does have a new booking link in the beginning, if the free span in front is more than 1 hour" do
        @calendar.draw_new_booking_first?(@booking4.machine_id, '2011-12-10'.to_date).should be_true
      end

      it "has a new booking link in the beginning, if it has no entry for a given date and machine" do
        @calendar.draw_new_booking_first?(@booking1.machine_id, '2011-12-01'.to_date).should be_true
      end

      it "has a new booking link in the beginning, if the first entry starts on that date and is no all day event" do
        @calendar.draw_new_booking_first?(@booking1.machine_id, '2011-12-08'.to_date).should be_true
      end
    end
    
    describe "new booking link after multiday event" do
      before :each do
        @booking = FactoryGirl.create(:booking)
        @calendar = Calendar.new
      end

      it "has a new booking link if it is multiday and it is not all day and it ends on that day and there's enough time after it" do
        @booking.stub(:multiday? => true, :all_day? => false, :ends_at? => true, :book_after_ok? => true)
        @calendar.draw_new_booking_after_mulitday?(@booking, Date.today).should be_true
      end

      it "has no new booking link if it is not multiday" do
        @booking.stub(:multiday? => false, :all_day? => false, :ends_at? => true, :book_after_ok? => true)
        @calendar.draw_new_booking_after_mulitday?(@booking, Date.today).should be_false
      end

      it "has no new booking link if it is an all day event" do
        @booking.stub(:multiday? => true, :all_day? => true, :ends_at? => true, :book_after_ok? => true)
        @calendar.draw_new_booking_after_mulitday?(@booking, Date.today).should be_false
      end

      it "has no new booking link if it does not end on that day" do
        @booking.stub(:multiday? => true, :all_day? => false, :ends_at? => false, :book_after_ok? => true)
        @calendar.draw_new_booking_after_mulitday?(@booking, Date.today).should be_false
      end

      it "has no new booking link if there's not enough time after it" do
        @booking.stub(:multiday? => true, :all_day? => false, :ends_at? => true, :book_after_ok? => false)
        @calendar.draw_new_booking_after_mulitday?(@booking, Date.today).should be_false
      end
    end
  end

  describe "draw booking" do
    before :each do
      @booking = FactoryGirl.create(:booking)
      @calendar = Calendar.new
    end

    it "is true if booking starts at that day" do
      @booking.stub(:starts_at? => true)
      @calendar.draw_booking?(@booking, Date.today).should be_true
    end

    it "is true if booking does not start at that day, but it is the first day of that calendar" do
      @booking.stub(:starts_at? => false)
      @calendar.draw_booking?(@booking, @calendar.days.first).should be_true
    end
    
    it "is false if booking does not start at that day, and it is not the first day of that calendar" do
      @booking.stub(:starts_at? => false)
      @calendar.draw_booking?(@booking, @calendar.days.first + 1.day).should be_false
    end
  end

  it "counts the number of entries for a given date" do
    @machine1, @machine2, @machine3= FactoryGirl.create_list(:machine,3)
    @booking1 = FactoryGirl.create(:booking, :starts_at => '2011-12-2 02:00:00', :ends_at => '2011-12-2 06:00:00', :machine => @machine1)
    @booking2 = FactoryGirl.create(:booking, :starts_at => '2011-12-2 02:00:00', :ends_at => '2011-12-2 06:00:00', :machine => @machine2, :all_day => true)
    @booking3 = FactoryGirl.create(:booking, :starts_at => '2011-12-3 00:00:50', :ends_at => '2011-12-3 03:00:00', :machine => @machine2)
    @booking4 = FactoryGirl.create(:booking, :starts_at => '2011-12-3 05:00:00', :ends_at => '2011-12-4 22:01:00', :machine => @machine2)
    @booking5 = FactoryGirl.create(:booking, :starts_at => '2011-12-3 12:00:00', :ends_at => '2011-12-3 23:00:01', :machine => @machine1)
    @booking6 = FactoryGirl.create(:booking, :starts_at => '2011-12-2 12:00:00', :ends_at => '2011-12-3 11:00:00', :machine => @machine3)

    @calendar = Calendar.new('2011-12-1'.to_date)
    
    @calendar.number_of_entries(@machine1.id, '2011-12-1'.to_date).should == 1
    @calendar.number_of_entries(@machine1.id, '2011-12-2'.to_date).should == 3
    @calendar.number_of_entries(@machine1.id, '2011-12-3'.to_date).should == 2
    @calendar.number_of_entries(@machine2.id, '2011-12-2'.to_date).should == 1
    @calendar.number_of_entries(@machine2.id, '2011-12-3'.to_date).should == 3
    @calendar.number_of_entries(@machine2.id, '2011-12-4'.to_date).should == 2
    @calendar.number_of_entries(@machine2.id, '2011-12-5'.to_date).should == 1
    @calendar.number_of_entries(@machine3.id, '2011-12-3'.to_date).should == 2

    @calendar.max_entries('2011-12-1'.to_date).should == 1
    @calendar.max_entries('2011-12-2'.to_date).should == 3
    @calendar.max_entries('2011-12-3'.to_date).should == 3
    @calendar.max_entries('2011-12-4'.to_date).should == 2
    @calendar.max_entries('2011-12-5'.to_date).should == 1
  end

  describe "next" do
    it "is the current end_date + 1 day" do
      @calendar.next.should == @calendar.days.last
    end
  end

  describe "prev" do
    it "is the current start_date - 4 weeks" do
      @calendar.prev.should == @calendar.days.first - 4.weeks
    end
  end

  describe "draw_new_booking after a booking" do
    it "is true, if booking ends on the date in question and the space after the booking is sufficient" do
      @booking = FactoryGirl.create(:booking)
      @booking.stub(:ends_at? => true, :book_after_ok? => true)
      @calendar = Calendar.new
      @calendar.draw_new_booking_after?(@booking, Date.today).should be_true
    end

    it "is false, if booking ends on the date in question and the space after the booking is not sufficient" do
      @booking = FactoryGirl.create(:booking)
      @booking.stub(:ends_at? => true, :book_after_ok? => false)
      @calendar = Calendar.new
      @calendar.draw_new_booking_after?(@booking, Date.today).should_not be_true
    end

    it "is false, if booking does not end on the date in question" do
      @booking = FactoryGirl.create(:booking)
      @booking.stub(:ends_at? => false, :book_after_ok? => true)
      @calendar = Calendar.new
      @calendar.draw_new_booking_after?(@booking, Date.today).should_not be_true
    end
  end
end

