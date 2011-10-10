require 'spec_helper'

describe "machines/new.html.haml" do
  before(:each) do
    assign(:machine, stub_model(Machine,
      :name => "MyString",
      :description => "MyText"
    ).as_new_record)
  end

  it "renders new machine form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => machines_path, :method => "post" do
      assert_select "input#machine_name", :name => "machine[name]"
      assert_select "textarea#machine_description", :name => "machine[description]"
    end
  end
end
