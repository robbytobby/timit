require 'spec_helper'

describe "accessories/show.html.haml" do
  before(:each) do
    @accessory = assign(:accessory, stub_model(Accessory,
      :name => "Name",
      :option_id => 1,
      :quantity => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
