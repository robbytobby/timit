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
        sign_in FactoryGirl.create(:user)
      end

      describe "GET index" do
        it "assigns a new calendar" do
          params = {:start_date => Date.today.to_s, :end_date => (Date.today + 4.weeks).to_s}
          Calendar.should_receive(:new).with(params[:start_date], params[:end_date], nil)
          get :index, params
        end
      end
    end
  end
end
