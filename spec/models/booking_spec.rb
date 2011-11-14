require 'spec_helper'

describe Booking do
  before :each do
  end
  it "includes all days between the starting and the anding day" do
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

  it "has a rage of days" do
    @booking = FactoryGirl.build(:booking, :starts_at => "2011-10-17 17:34:14", :ends_at =>"2011-10-19 17:34:14")
    @booking.days.class.should == Range
    @booking.days.first.should == @booking.starts_at.to_date
    @booking.days.last.should == @booking.ends_at.to_date
  end
end
