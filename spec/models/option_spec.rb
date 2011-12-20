require 'spec_helper'

describe Option do
  it{ should belong_to(:machine) }
  it{ should validate_presence_of(:name)}
  it "should not be valid" do
    FactoryGirl.build(:option, :name => '').should_not be_valid
  end
end
