require 'spec_helper'

describe "Calendar" do
  before :all do
    @user = FactoryGirl.create :approved_user
  end

  after :all do
    @user.destroy
  end

  before :each do
    post user_session_path, :user => {:email => @user.email, :password => 'password'}
  end

  describe "GET /index" do
    it "works! " do 
      get calendar_path
      response.status.should be(200)
    end

    it "shows the time span in the header"

    it "has links to the next and previous time span"
  end
end

