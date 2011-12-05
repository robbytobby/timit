require 'spec_helper'

describe CalendarController do
  include Devise::TestHelpers

  describe "GET index" do
    context "without user logged in" do
      describe "GET index" do
        it "redirects to login page" do
          get :index
          response.should redirect_to(new_user_session_path)
        end
      end
    end

    context "with user logged in" do
      before :each do
        sign_in FactoryGirl.create :approved_user
      end

      describe "GET index" do
        it "assigns a new calendar" do
          params = {:start_date => Date.today.to_s, :end_date => (Date.today + 4.weeks).to_s}
          Calendar.should_receive(:new).with(params[:start_date], params[:end_date], nil)
          get :index, params
        end

        it "assigns a new calendar" do
          get :index
          assigns(:calendar).should be_instance_of(Calendar)
        end

        its "start date defaults to today" do
          get :index
          assigns(:calendar).days.first.should == Date.today
        end

        its "end date defaults to today + 4 weeks" do
          get :index
          assigns(:calendar).days.last.should == Date.today + 4.weeks
        end

        its "start date may be set" do
          get :index, :start_date => (Date.today + 2.weeks)
          @calendar = assigns(:calendar)
          @calendar.days.first.should == (Date.today + 2.weeks)
          @calendar.days.last.should == (Date.today + 6.weeks)
        end

        its "end date may as well be set" do
          get :index, :end_date => Date.today + 1.week
          @calendar = assigns(:calendar)
          @calendar.days.first.should == Date.today
          @calendar.days.last.should == (Date.today + 1.weeks)
        end
      end
    end
  end
end
