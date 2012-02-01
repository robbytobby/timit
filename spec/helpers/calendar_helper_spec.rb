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

    it "marks the fields of the last row" do
      helper.row_class(@calendar, @calendar.days.last - 1.day).should include("last")
    end
  end

  describe "div_class" do
    before :each do
      @booking1 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 02:00:00', :ends_at => '2011-12-1 03:00:00')
      @booking2 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 02:00:00', :ends_at => '2011-12-2 02:00:00')
      @booking3 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 02:00:00', :ends_at => '2011-12-2 02:00:00', :all_day => true)
      @booking4 = FactoryGirl.create(:booking, :starts_at => '2011-12-1 00:59:00', :ends_at => '2011-12-2 02:00:00')
      @booking5 = FactoryGirl.create(:booking, :starts_at => '2011-11-28 00:59:00', :ends_at => '2011-12-2 02:00:00')
      @booking6 = FactoryGirl.create(:booking, :starts_at => '2011-12-28 00:59:00', :ends_at => '2012-01-2 02:00:00')
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

    it "labels events that start from near midnight" do
      helper.div_class(@calendar, @booking4).should include("from_midnight")
    end

    it "labels events that start in the previos calender period" do
      helper.div_class(@calendar, @booking5).should include("end")
    end

    it "labels events that end in the next calendar period" do
      helper.div_class(@calendar, @booking6).should include("start")
    end
  end

  describe "new_booking_link" do
    before :each do
      @machine = FactoryGirl.create(:machine)
      @machine2 = FactoryGirl.create(:machine, :max_duration => '3', :max_duration_unit => 'day')
      @user = FactoryGirl.create :approved_user
    end

    def current_user
      @user
    end


    it "creates a link to a new booking for a given date and machine" do
      new_booking_link(@machine, Date.today).should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine,
                                                               :starts_at => Date.today.to_datetime,
                                                               :ends_at => Date.today.to_datetime + 1.week,
                                                               :user_id => current_user.id}))
    end

    it "creates a link to a new booking for a given date and machine and respects the maximum duration" do
      new_booking_link(@machine2, Date.today).should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine2,
                                                               :starts_at => Date.today.to_datetime,
                                                               :ends_at => Date.today.to_datetime + @machine2.real_max_duration,
                                                               :user_id => current_user.id}))
    end


    it "creates a link to a new booking for a given date and machine with corect start if after is given" do
      @machine = FactoryGirl.create(:machine, :max_duration => 1, :max_duration_unit => 'week')
      @booking = FactoryGirl.create(:booking, :starts_at => '2011-12-01 00:00:00' , :ends_at => '2011-12-01 02:00:00')
      new_booking_link(@machine, Date.today, :after => @booking).should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine,
                                                               :starts_at => '2011-12-01 02:00:00 UTC',
                                                               :ends_at => '2011-12-08 02:00:00 UTC',
                                                               :user_id => current_user.id}))
    end

    context "with a booking after it" do
      it "creates a link to a new booking for a given date and machine that ends before the next booking" do
        other_booking = FactoryGirl.create(:booking, :machine => @machine2, :starts_at => Date.today + 1.day + 3.hours, :ends_at => Date.today + 3.days)
        new_booking_link(@machine2, Date.today).should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine2,
                                                                 :starts_at => Date.today.to_datetime,
                                                                 :ends_at => other_booking.starts_at,
                                                                 :user_id => current_user.id}))
      end

      it "creates a link to a new booking for a given date and machine that ends before the next booking and has max duration" do
        other_booking = FactoryGirl.create(:booking, :machine => @machine2, :starts_at => Date.today + 7.days + 3.hours, :ends_at => Date.today + 8.days)
        new_booking_link(@machine2, Date.today).should have_selector(:a, :href => new_booking_path(:booking => {:machine_id => @machine2,
                                                                 :starts_at => Date.today.to_datetime,
                                                                 :ends_at => Date.today.to_datetime + @machine2.real_max_duration,
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

  describe "calendar_link" do
    it "creates a link to calendar index with the name given" do
      calendar_link('test').should have_selector(:a, :href => "/de/calendar?start_date=#{Date.today.to_s}", :content => "test")
    end

    it "even accecpts other tags as name" do
      helper.calendar_link(content_tag(:div, 'test', :class => 'test')).should have_selector(:a) do |a|
        a.should have_selector(:div, :class => 'test', :content => 'test')
      end
    end

    it "respects a given start date" do
      calendar_link('test', start_date: Date.tomorrow).should have_selector(:a, :href => "/de/calendar?start_date=#{Date.tomorrow.to_s}", :content => "test")
    end

    it "respects a given machine offset" do
      calendar_link('test', machine_offset: 2).should have_selector(:a, :href => "/de/calendar?machine_offset=2&start_date=#{Date.today}", :content => "test")
    end

    it "has default values" do
      pending 'kann den fehler nicht finden'
      @machines = FactoryGirl.create_list(:machine, 3)
      @calendar = Calendar.new(nil, nil, [@machines[0].id, @machines[2].id], 1)
      calendar_link('test').should have_selector(:a, :href => "/calendar?machine_offset=1&machines[#{@machines[0].id}]=1&machines[#{@machines[2].id}]=1&start_date=#{Date.today.to_s}", :content => "test")
    end
  end

  describe "prev_machine_link?" do
    it "is true if the offset is > 0" do
      @calendar = Calendar.new(nil, nil, [], 1)
      prev_machine_link?.should be_true
    end

    it "is false otherwise" do
      @calendar = Calendar.new(nil, nil, [], 0)
      prev_machine_link?.should be_false
    end
  end

  describe "next_machine_link?" do
    it "is true only if it the last shown machine and it is not the last of the calendar" do
      @machines = FactoryGirl.create_list(:machine, 6)
      @calendar = Calendar.new(nil, nil, [], 0)
      next_machine_link?(@machines[0], 0).should be_false
      next_machine_link?(@machines[4], 4).should be_true
      @calendar = Calendar.new(nil, nil, [], 1)
      next_machine_link?(@machines[4], 4).should be_false
      next_machine_link?(@machines[5], 5).should be_false
    end
  end

  describe "draw_machine?" do
    it "is true if the index is greater or equal than the offset, and less then the max shown" do
      @machines = FactoryGirl.create_list(:machine, 7)
      @calendar = Calendar.new(nil, nil, [], 1)
      draw_machine?(0).should be_false
      draw_machine?(1).should be_true
      draw_machine?(5).should be_true
      draw_machine?(6).should be_false
    end
  end
end
