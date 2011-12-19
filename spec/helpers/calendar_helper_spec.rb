require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the CalendarHelper. For example:
#
# describe CalendarHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe CalendarHelper do
  before :each do
    @calendar = Calendar.new
  end

  describe "row class" do
    it "delivers a string" do
      helper.row_class(@calendar, Date.today).should be_a(String)
    end

    it "contains the day of week" do
      helper.row_class(@calendar, Date.today).should include("day#{Date.today.wday}")
    end

    it "cycles odd and even rows" do
      helper.row_class(@calendar, Date.today).should include("even")
      helper.row_class(@calendar, Date.today).should include("odd")
    end

    it "defines the row_height" do
      @calendar.stub(:max_entries => 3)
      helper.row_class(@calendar, Date.today).should include("height-3")
    end
  end

  describe "div_class" do
    before :each do
      @booking1 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 02:00:00', :ends_at => '2011-12-1 03:00:00')
      @booking2 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 02:00:00', :ends_at => '2011-12-2 02:00:00')
      @booking3 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 02:00:00', :ends_at => '2011-12-2 02:00:00', :all_day => true)
      @calendar = Calendar.new('2011-12-1'.to_date)
    end

    it "delivers a string" do
      helper.div_class(@calendar, @booking1).should be_a(String)
    end

    it "labels multiday bookings" do
      helper.div_class(@calendar, @booking2).should include("multiday")
      helper.div_class(@calendar, @booking1).should_not include("multiday")
    end

    it "labels all_day events" do
      helper.div_class(@calendar, @booking3).should include("all_day")
      helper.div_class(@calendar, @booking2).should_not include("all_day")
    end

    it "defines the height of a div" do
      helper.div_class(@calendar, @booking1).should include("height-1-0")
      helper.div_class(@calendar, @booking2).should include("height-3-1")
      helper.div_class(@calendar, @booking3).should include("height-5-3")
    end
  end

  describe "new_booking" do
    before :each do
      @machine = FactoryGirl.create(:machine)
      @machine2 = FactoryGirl.create(:machine, :max_duration => '3', :max_duration_unit => 'day')
      @user = FactoryGirl.create :approved_user
    end

    def current_user
      @user
    end


    it "creates a link to a new booking for a given date and machine" do
      new_booking(@machine, Date.today).should have_selector(:div) do |div|
        div.should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine,
                                                               :starts_at => Date.today.to_datetime,
                                                               :ends_at => Date.today.to_datetime + 1.week,
                                                               :user_id => current_user.id}))
      end
    end

    it "creates a link to a new booking for a given date and machine and respects the maximum duration" do
      new_booking(@machine2, Date.today).should have_selector(:div) do |div|
        div.should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine2,
                                                               :starts_at => Date.today.to_datetime,
                                                               :ends_at => Date.today.to_datetime + @machine2.real_max_duration,
                                                               :user_id => current_user.id}))
      end
    end

    it "creates a link to a new booking for a given date and machine with corect start if after is given" do
      @machine = FactoryGirl.create(:machine, :max_duration => 1, :max_duration_unit => 'week')
      @booking = FactoryGirl.create(:booking, :starts_at => '2011-12-01 00:00:00' , :ends_at => '2011-12-01 02:00:00')
      new_booking(@machine, Date.today, :after => @booking).should have_selector(:div) do |div|
        div.should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine,
                                                               :starts_at => '2011-12-01 02:00:00 UTC',
                                                               :ends_at => '2011-12-08 02:00:00 UTC',
                                                               :user_id => current_user.id}))
      end
    end

  
  end


  describe "draw_spacer" do
    before :each do
      @booking1 = FactoryGirl.create(:booking, :starts_at => Time.now, :ends_at => Time.now + 2.hours)
      @booking2 = FactoryGirl.create(:booking, :starts_at => Time.now, :ends_at => Time.now + 2.days) 
      @calendar = Calendar.new
    end

    it "does nothing if the first entry for a day is no multiday booking" do
      draw_spacer(@calendar, @booking1.machine_id, @booking1.days.first).should == nil
    end

    it "does nothing if there is no entry for a day" do
      draw_spacer(@calendar, @booking1.machine_id, Date.today + 1.week).should == nil
    end

    it "does nothing if the first entry is a multiday event, but this is not its last day" do
      draw_spacer(@calendar, @booking2.machine_id, Date.today).should == nil
    end

    it "draws a spacer div if the first booking for a given date and machine is a multiday event and it is the last day of that booking" do
      draw_spacer(@calendar, @booking2.machine_id, @booking2.days.last).should have_selector(:div, :class => "spacer")
    end
  end
end
