require 'spec_helper'

describe "bookings/show.html.haml" do
  include Devise::TestHelpers

  before(:each) do
    @booking = assign(:booking, FactoryGirl.create(:booking))
    sign_in (@current_user = FactoryGirl.create(:admin_user))
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
