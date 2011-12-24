require 'spec_helper'

describe "accessories/index.html.haml" do
  before(:each) do
    assign(:accessories, FactoryGirl.create_list(:accessory, 3) )
  end

  it "renders a list of accessories"
end
