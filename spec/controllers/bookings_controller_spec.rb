require 'spec_helper'

describe BookingsController do
  include Devise::TestHelpers

  def valid_attributes
    FactoryGirl.build(:booking).attributes.symbolize_keys
  end
  
  after :all do
    Machine.destroy_all
    User.destroy_all
  end

  context "as an admin user" do
    before :each do
      sign_in (@current_user = FactoryGirl.create(:admin_user))
      @booking = FactoryGirl.create(:booking)
    end

    describe "GET index" do
      it "assigns all bookings as @bookings" do
        get :index
        assigns(:bookings).should eq([@booking])
      end
    end

    describe "GET show" do
      it "assigns the requested booking as @booking" do
        get :show, :id => @booking.id.to_s
        assigns(:booking).should eq(@booking)
      end
    end

    describe "GET new" do
      it "assigns a new booking as @booking" do
        get :new
        assigns(:booking).should be_a_new(Booking)
      end

      it "saves referrer in the session" do
        @request.env['HTTP_REFERER'] = 'http://www.test'
        get :new
        session[:return_to].should == 'http://www.test'
      end

      it "renders the template if a machine is selected" do
        @machine = FactoryGirl.create(:machine)
        get :new, :booking => {:machine_id => @machine.id}
        response.should render_template :new
      end

      it "redirect_to the calendar if no machine is selected" do
        get :new
        response.should redirect_to calendar_path
      end
    end

    describe "GET edit" do
      it "assigns the requested booking as @booking" do
        get :edit, :id => @booking.id.to_s
        assigns(:booking).should eq(@booking)
      end

      it "saves referrer in the session" do
        @request.env['HTTP_REFERER'] = 'http://www.test'
        get :edit, :id => @booking.id.to_s
        session[:return_to].should == 'http://www.test'
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Booking" do
          expect {
            post :create, :booking => valid_attributes
          }.to change(Booking, :count).by(1)
        end

        it "assigns a newly created booking as @booking" do
          post :create, :booking => valid_attributes
          assigns(:booking).should be_a(Booking)
          assigns(:booking).should be_persisted
        end

        it "redirects to the calendar by default" do
          post :create, :booking => valid_attributes
          response.should redirect_to(:calendar)
        end

        it "redirects to the url saved in session" do
          session[:return_to] = calendar_path(:start_date => Date.today - 3.weeks)
          post :create, :booking => valid_attributes
          response.should redirect_to(session[:return_to])
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved booking as @booking" do
          Booking.any_instance.stub(:save).and_return(false)
          post :create, :booking => {}
          assigns(:booking).should be_a_new(Booking)
        end

        it "re-renders the 'new' template" do
          Booking.any_instance.stub(:save).and_return(false)
          post :create, :booking => {}
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested booking" do
          Booking.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => @booking.id, :booking => {'these' => 'params'}
        end

        it "assigns the requested booking as @booking" do
          put :update, :id => @booking.id, :booking => valid_attributes
          assigns(:booking).should eq(@booking)
        end

        it "redirects to the booking per default to the calendar" do
          put :update, :id => @booking.id, :booking => valid_attributes
          response.should redirect_to(:calendar)
        end

        it "redirects to the url saved in session" do
          session[:return_to] = calendar_path(:start_date => Date.today - 3.weeks)
          put :update, :id => @booking.id, :booking => valid_attributes
          response.should redirect_to(session[:return_to])
        end

        it "sends an email to booking.user if current_user != booking.user" do
          UserMailer.should_receive(:booking_updated_notification).with(@current_user, instance_of(Booking), instance_of(Booking)).and_return(@mail = mock(Mail, :deliver => true))
          put :update, :id => @booking.id, :booking => valid_attributes
        end
      end

      describe "with invalid params" do
        it "assigns the booking as @booking" do
          Booking.any_instance.stub(:save).and_return(false)
          put :update, :id => @booking.id.to_s, :booking => {}
          assigns(:booking).should eq(@booking)
        end

        it "re-renders the 'edit' template" do
          Booking.any_instance.stub(:save).and_return(false)
          put :update, :id => @booking.id.to_s, :booking => {}
          response.should render_template("edit")
        end

        it "does not send an email to booking.user if current_user != booking.user" do
          Booking.any_instance.stub(:save).and_return(false)
          UserMailer.should_not_receive(:booking_updated_notification)
          put :update, :id => @booking.id, :booking => valid_attributes
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested booking" do
        expect {
          delete :destroy, :id => @booking.id.to_s
        }.to change(Booking, :count).by(-1)
      end

      it "redirects to the calendar per default" do
        delete :destroy, :id => @booking.id.to_s
        response.should redirect_to(calendar_path)
      end

      it "redirects to the url saved in session" do
        @request.env['HTTP_REFERER'] = 'http://www.test'
        delete :destroy, :id => @booking.id.to_s
        response.should redirect_to('http://www.test')
      end

      it "sends an email to booking.user if current_user != booking.user" do
        UserMailer.stub(:booking_deleted_notification => @mail = mock(Mail, :deliver => true))
        UserMailer.should_receive(:booking_deleted_notification).with(@current_user, @booking)
        delete :destroy, :id => @booking.id.to_s
      end
    end
  end

  context "as an unprivileged user" do
    describe "POST create" do
      before :each do
        sign_in @user = FactoryGirl.create(:unprivileged_user)
        @own_booking = FactoryGirl.build(:booking, :user => @user)
        @other_boooking = FactoryGirl.build(:booking)
      end

      it "is not possible to create a booking for another user" do
        expect {
          post :create, :booking => @other_boooking.attributes
        }.not_to change(Booking.where(:user_id => @other_boooking.user_id), :count)
      end

      it "it is possible to create own bookings" do
        expect {
          post :create, :booking => @own_booking.attributes
        }.to change(Booking.where(:user_id => @user.id), :count).by(1)
      end
    end

    describe "PUT update" do
      before :each do
        sign_in @user = FactoryGirl.create(:unprivileged_user)
        @own_booking = FactoryGirl.create(:booking, :user => @user)
        @other_booking = FactoryGirl.create(:booking)
      end

      it "is not possible to change bookings of others" do
        put :update, :id => @other_booking.id, :booking => {'ends_at' => @other_booking.ends_at + 2.hours}
        @other_booking.ends_at.should_not == @other_booking.reload.ends_at
      end

      it "is possible to change own bookings" do
        put :update, :id => @own_booking.id, :booking => {'ends_at' => @own_booking.ends_at + 2.hours}
        @own_booking.ends_at.should_not == @own_booking.reload.ends_at
      end
    end
  end
end
