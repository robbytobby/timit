require 'spec_helper'

describe Machine do
  it {should_not accept_values_for(:name, '', nil, ' ')}

  it "strips white spaces of attributes" do
    [:name, :description].each do |attr|
      machine = FactoryGirl.build(:machine, attr =>  ' Test ')
      machine.valid?
      machine.send(attr).should == 'Test'
    end
  end
  
  it "has a uniq name" do
    FactoryGirl.create(:machine, :name => 'This')
    FactoryGirl.build(:machine, :name => 'That').should be_valid
    FactoryGirl.build(:machine, :name => 'This').should_not be_valid
  end
end
