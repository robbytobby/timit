require 'spec_helper'

describe OptionGroup do
  it { should have_many(:options).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should accept_values_for(:optional, true, false) }
  it { should_not accept_values_for(:optional, '', nil, ' ') }
  it { should accept_values_for(:exclusive, true, false) }
  it { should_not accept_values_for(:exclusive, '', nil, ' ') }
  it "should be valid" do
    FactoryGirl.build(:option_group).should be_valid
  end
end
