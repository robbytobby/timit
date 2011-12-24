require 'spec_helper'

describe OptionGroup do
  before(:each){FactoryGirl.create(:option_group)}
  it { should have_many(:options).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should accept_values_for(:optional, true, false) }
  it { should_not accept_values_for(:optional, '', nil, ' ') }
  it { should accept_values_for(:exclusive, true, false) }
  it { should_not accept_values_for(:exclusive, '', nil, ' ') }
  it("should be valid"){ FactoryGirl.build(:option_group).should be_valid }
end
