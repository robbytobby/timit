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
      helper.row_class(@calendar, Date.today).should include("odd")
      helper.row_class(@calendar, Date.today).should include("even")
    end

    it "defines the row_height" do
      @calendar.stub(:max_entries => 3)
      helper.row_class(@calendar, Date.today).should include("height-3")
    end
  end

  describe "div_class" do
    before :each do
      @booking1 = FactoryGirl.create(:booking, :starts_at => Time.now, :ends_at => Time.now + 1.hour)
      @booking2 = FactoryGirl.create(:booking, :starts_at => Time.now, :ends_at => Time.now + 1.day)
      @booking3 = FactoryGirl.create(:booking, :starts_at => Time.now, :ends_at => Time.now + 1.day, :all_day => true)
    end

    it "delivers a string" do
      helper.div_class(@calendar, @booking1).should be_a(String)
    end

    it "contains 'booked'" do
      helper.div_class(@calendar, @booking1).should include("booked")
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
      helper.div_class(@calendar, @booking2).should include("height-2-0")
      helper.div_class(@calendar, @booking3).should include("height-4-2")
    end
  end

  describe "new_booking" do
    before :each do
      @machine = FactoryGirl.create(:machine)
    end

    it "creates a link to a new booking for a given date and machine" do
      new_booking(@machine, Date.today).should have_selector(:div) do |div|
        div.should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine, :starts_at => Date.today.to_datetime}))
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
