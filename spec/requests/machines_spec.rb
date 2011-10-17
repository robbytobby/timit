require 'spec_helper'

describe "Machines" do
  context "without login" do
    describe "GET /machines" do
      it "works! (now write some real specs)" do
        # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
        get machines_path
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  context "with login" do
    before :all do
      @user = FactoryGirl.create :user
    end

    after :all do
      @user.destroy
    end

    before :each do
      post user_session_path, :user => {:email => @user.email, :password => 'password'}
    end

    describe "GET /machines" do
      it "works! (now write some real specs)" do
        # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
        get machines_path
        response.status.should == 200
      end
    end
  end
end


