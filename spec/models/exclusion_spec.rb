require 'spec_helper'

describe Exclusion do
  it { should be_valid }
  it { should belong_to(:option) }
  it { should belong_to(:excluded_option) }

  it "create the inverse relation after create" do
    @exclusion1 = FactoryGirl.create(:exclusion)
    Exclusion.where(:option_id => @exclusion1.excluded_option_id, :excluded_option_id => @exclusion1.option_id).all.should_not be_empty
  end

  it "destroys the inverse relation after destroy" do
    @exclusion1 = FactoryGirl.create(:exclusion)
    @exclusion1.destroy
    Exclusion.where(:option_id => @exclusion1.excluded_option_id, :excluded_option_id => @exclusion1.option_id).all.should be_empty
  end

end
