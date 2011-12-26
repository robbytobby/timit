require 'spec_helper'

describe "accessories/new.html.haml" do
  before(:each) do
    assign(:accessory, FactoryGirl.build(:accessory))
  end

  it "renders new accessory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accessories_path, :method => "post" do
      assert_select "input#accessory_name", :name => "accessory[name]"
      assert_select "input#accessory_quantity", :name => "accessory[quantity]"
    end
  end
end
