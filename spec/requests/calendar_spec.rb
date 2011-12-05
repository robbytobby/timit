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

    it "has links to the next and previous time span" do
      get calendar_path
      @calendar = assigns(:calendar)
      response.body.should have_selector(:a, :href => calendar_path(:start_date => @calendar.next) )
      response.body.should have_selector(:a, :href => calendar_path(:start_date => @calendar.prev) )
    end

    it "shows the time span in the header" do
      get calendar_path
      @calendar = assigns(:calendar)
      response.body.should have_selector(:h2) do |h2|
        h2.should contain(I18n.l(@calendar.days.first))
      end
    end

  end
end

