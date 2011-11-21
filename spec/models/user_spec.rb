require 'spec_helper'

describe User do
  it "needs to be approved before being able to sign in" do
    @user = FactoryGirl.create(:user, :approved => false)
    @user.should_not be_active_for_authentication

    @user = FactoryGirl.create(:user, :approved => true)
    @user.should be_active_for_authentication
  end
end
