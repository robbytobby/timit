require 'spec_helper'

describe "bookings/edit.html.haml" do
  before(:each) do
    @booking = assign(:booking, stub_model(Booking,
      :all_day => false,
      :user_id => 1,
      :machine_id => 1
    ))
  end

  it "renders the edit booking form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bookings_path(@booking), :method => "post" do
      assert_select "input#booking_all_day", :name => "booking[all_day]"
      assert_select "input#booking_user_id", :name => "booking[user_id]"
      assert_select "input#booking_machine_id", :name => "booking[machine_id]"
    end
  end
end
