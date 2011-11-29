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
      @booking1 = FactoryGirl.create(:booking, :starts_at => Time.now + 1.day, :ends_at => Time.now + 2.days)
      @booking2 = FactoryGirl.create(:booking, :starts_at => Time.now + 1.day, :ends_at => Time.now + 2.days, :all_day => true)
      @booking3 = FactoryGirl.create(:booking, :starts_at => Time.now.beginning_of_day + 6.days + 59.minutes, :ends_at => Time.now + 7.days, :all_day => false)
      @calendar = Calendar.new(Date.today, Date.today + 1.week)
    end

    after :all do
      Booking.destroy_all
      User.destroy_all
      Machine.destroy_all
    end

    it "does not have a new booking link in the beginning, if the first entry for a given date and machine starts in the past" do
      @calendar.draw_new_booking_first?(@booking1.machine_id, Date.today + 2.days).should be_false
    end

    it "does not have a new booking link in the beginning, if the first entry for a given date and machine is an all day event" do
      @calendar.draw_new_booking_first?(@booking2.machine_id, Date.today + 1.day).should be_false
    end

    it "does not have a new booking link in the beginning, if the free span in fron is less than 1 hour" do
      pending 'does not test the right thing'
      @calendar.draw_new_booking_first?(@booking3.machine_id, Date.today + 6.days).should be_false
    end

    it "has a new booking link in the beginning, if it has no entry for a given date and machine" do
      @calendar.draw_new_booking_first?(@booking1.machine_id, Date.today + 3.days).should be_true
    end

    it "has a new booking link in the beginning, if the first entry starts on that date and is no all day event" do
      @calendar.draw_new_booking_first?(@booking1.machine_id, Date.today + 1.days).should be_true
    end

    it "has a new booking link as last item, if the last entry ends on that date and is no all day event" do
      @calendar.draw_new_booking_last?(@booking1.machine_id, @booking1.ends_at.to_date).should be_true 
      @calendar.draw_new_booking_last?(@booking1.machine_id, @booking1.starts_at.to_date).should be_false
      @calendar.draw_new_booking_last?(@booking2.machine_id, @booking2.ends_at.to_date).should be_false
    end
    
    it "does not have a new booking link as last item if it allready has a new booking link" do
      @calendar.stub(:draw_new_booking_first? => true)
      @calendar.draw_new_booking_last?(@booking1.machine_id, @booking1.ends_at.to_date).should be_false
      @calendar.stub(:draw_new_booking_first? => false)
      @calendar.draw_new_booking_last?(@booking1.machine_id, @booking1.ends_at.to_date).should be_true
    end

    it "know if it draws a new bookin link" do
      @calendar.stub(:draw_new_booking_first? => true, :draw_new_booking_last? => false)
      @calendar.draw_new_booking_link?(@booking1.machine_id, Date.today).should be_true

      @calendar.stub(:draw_new_booking_first? => false, :draw_new_booking_last? => true)
      @calendar.draw_new_booking_link?(@booking1.machine_id, Date.today).should be_true

      @calendar.stub(:draw_new_booking_first? => false, :draw_new_booking_last? => false)
      @calendar.draw_new_booking_link?(@booking1.machine_id, Date.today).should be_false
    end
  end

  it "counts the number of entries for a given date" do
    @machine1, @machine2 = FactoryGirl.create_list(:machine,2)
    @booking1 = FactoryGirl.create(:booking, :starts_at => Time.now + 1.day, :ends_at => Time.now + 1.day, :machine_id => @machine1.id)
    @booking2 = FactoryGirl.create(:booking, :starts_at => Time.now + 1.day, :ends_at => Time.now + 1.day, :machine_id => @machine2.id, :all_day => true)
    @booking3 = FactoryGirl.create(:booking, :starts_at => Time.now + 2.days, :ends_at => Time.now + 2.days + 2.hours, :machine_id => @machine2.id)
    @booking4 = FactoryGirl.create(:booking, :starts_at => Time.now + 2.days + 3.hours, :ends_at => Time.now + 4.days, :machine_id => @machine2.id)
    @calendar = Calendar.new
    
    @calendar.number_of_entries(@machine1.id, Date.today).should == 1
    @calendar.number_of_entries(@machine1.id, Date.today + 1.day).should == 2
    @calendar.number_of_entries(@machine2.id, Date.today + 1.day).should == 1
    @calendar.number_of_entries(@machine2.id, Date.today + 2.days).should == 3
    @calendar.number_of_entries(@machine2.id, Date.today + 3.days).should == 1
    @calendar.number_of_entries(@machine2.id, Date.today + 4.days).should == 2

    @calendar.max_entries(Date.today).should == 1
    @calendar.max_entries(Date.today + 1.day).should == 2
    @calendar.max_entries(Date.today + 2.days).should == 3
    @calendar.max_entries(Date.today + 3.days).should == 1
    @calendar.max_entries(Date.today + 4.days).should == 2
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
end

