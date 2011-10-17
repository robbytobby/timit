require 'spec_helper'

describe "bookings/show.html.haml" do
  before(:each) do
    @booking = assign(:booking, stub_model(Booking,
      :all_day => false,
      :user_id => 1,
      :machine_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
