require 'spec_helper'

describe "bookings/index.html.haml" do
  before(:each) do
    assign(:bookings, [
      stub_model(Booking,
        :starts_at => Time.now,
        :ends_at => Time.now + 5.hours,
        :all_day => false,
        :user_id => 1,
        :machine_id => 1
      ),
      stub_model(Booking,
        :starts_at => Time.now + 1.day,
        :ends_at => Time.now + 35.hours,
        :all_day => false,
        :user_id => 2,
        :machine_id => 2
      )
    ])
  end

  it "renders a list of bookings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
