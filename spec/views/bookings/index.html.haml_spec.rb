require 'spec_helper'

describe "bookings/index.html.haml" do
  before(:each) do
    assign(:bookings, FactoryGirl.create_list(:booking, 2))
  end

  it "delete spec/views/bookings/index.html.haml_spec.rb or write some specs" 
end
