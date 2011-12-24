require 'spec_helper'

describe "accessories/edit.html.haml" do
  before(:each) do
    @accessory = assign(:accessory, stub_model(Accessory,
      :name => "MyString",
      :option_id => 1,
      :quantity => 1
    ))
  end

  it "renders the edit accessory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accessories_path(@accessory), :method => "post" do
      assert_select "input#accessory_name", :name => "accessory[name]"
      assert_select "input#accessory_option_id", :name => "accessory[option_id]"
      assert_select "input#accessory_quantity", :name => "accessory[quantity]"
    end
  end
end
