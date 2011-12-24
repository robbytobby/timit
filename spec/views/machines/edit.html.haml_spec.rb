require 'spec_helper'

describe "machines/edit.html.haml" do
  before(:each) do
    @options = assign(:options, FactoryGirl.create_list(:option, 3))
    @machine = assign(:machine, FactoryGirl.create(:machine))
  end

  it "renders the edit machine form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => machines_path(@machine), :method => "post" do
      assert_select "input#machine_name", :name => "machine[name]"
      assert_select "textarea#machine_description", :name => "machine[description]"
    end
  end
end
