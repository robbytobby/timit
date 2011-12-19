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
          Calendar.should_receive(:new).with(params[:start_date], params[:end_date], [], nil)
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
        
        it "respects the choice of machines" do
          @machines = FactoryGirl.create_list(:machine, 5)
          get :index, :machines => {@machines[0].id => 1, @machines[2].id => 1, @machines[4].id => 1}
          @calendar = assigns(:calendar)
          @calendar.machines.should include(@machines[0], @machines[2], @machines[4])
          @calendar.machines.should have(3).machines
          @calendar.machines.should_not include(@machines[1], @machines[3], @machines[5])
        end

        it "respects an offset for machines" do
          @machines = FactoryGirl.create_list(:machine, 7)
          get :index, :machine_offset => 1
          @calendar = assigns(:calendar)
          @calendar.machine_offset.should == 1
        end
      end
    end
  end
end
