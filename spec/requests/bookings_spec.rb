require 'spec_helper'

describe "Bookings" do
  def session_for(role)
    @current_user = FactoryGirl.create "#{role}_user".to_sym, :approved => true
    post user_session_path, :user => {:email => @current_user.email, :password => 'password'}
  end

  def access_check(role, success, result = {:success => nil, :failure => lambda{redirect_to(root_url)}}, &block)
    session_for role
    yield
    if success
      if result[:success]
        response.should result[:success].call
      else
        response.status.should == 200
      end
    else
      response.should result[:failure].call
    end
  end

  ### Anonymus
  context "without login" do
    describe "GET /bookings" do
      it "redirects to login path" do
        get bookings_path
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  ### As User
  context "with login" do
    describe "GET /bookings" do
      before :each do
        @bookings = FactoryGirl.create_list(:booking, 2)
      end

      it "shows the index page for all users" do
        User.roles.each{|r| access_check(r, true){get bookings_path} }
      end

      it "shows the bookings" do
        session_for :unprivileged
        get bookings_path
        response.should render_template(:index)
      end

      it "has the right content" 

      it "does not show edit and destroy links for unprivileged users" do
        @bookings = FactoryGirl.create_list(:booking, 2)
        session_for :unprivileged
        get bookings_path
        response.should render_template(:index)
        response.body.should_not have_selector(:a, :href => edit_booking_path(@bookings.first))
        response.body.should_not have_selector(:a, :href => booking_path(@bookings.first), 'data-method' => 'delete')
      end


      it "does show, edit and destroy links for admin and teaching users" do
        @bookings = FactoryGirl.create_list(:booking, 2)
        session_for :teaching
        get bookings_path
        response.should render_template(:index)
        response.body.should have_selector(:a, :href => edit_booking_path(@bookings.first))
        response.body.should have_selector(:a, :href => booking_path(@bookings.first), 'data-method' => 'delete')
      end
    end

    describe "GET show" do
      before :each do
        @booking = FactoryGirl.create(:booking)
      end

      it "shows the booking for all users" do
        User.roles.each{|r| access_check(r, true){get booking_path(@booking)} }
      end

      it "shows the right content"
    end

    describe "GET new" do
      it "shows the new booking form for all users" do
        User.roles.each{|r| access_check(r, true){get new_booking_path} }
      end

      it "shows the right content"
    end

    describe "GET edit" do
      context "as an unprivileged user" do
        it "shows edit form for own bookings" do
          access_check(:unprivileged, true){get edit_booking_path(FactoryGirl.create(:booking, :user => @current_user))}
        end
        
        it "redirects to root url for bookings of others" do
          access_check(:unprivileged, false){get edit_booking_path(FactoryGirl.create(:booking))}
        end
      end

      [:teaching, :admin].each do |role|
        context "as a #{role} user" do
          it "shows edit form for own bookings" do
            access_check(role, true){get edit_booking_path(FactoryGirl.create(:booking, :user => @current_user))}
          end
          
          it "show edit form for bookings of others" do
            access_check(role, true){get edit_booking_path(FactoryGirl.create(:booking))}
          end
        end
      end
    end

    describe "POST /bookings" do
      context "as an unprivileged user" do
        it "creates bookings for the current_user" do
          access_check(:unprivileged, true, {:success => lambda{redirect_to(calendar_url)}}){post bookings_path, :booking => FactoryGirl.build(:booking, :user_id => @current_user.id).attributes}
        end

        it "does not create bookings for other users" do
          access_check(:unprivileged, false){post bookings_path, :booking => FactoryGirl.build(:booking).attributes}
        end
      end

      [:teaching, :admin].each do |role|
        context "as a role user" do
          it "creates bookings for the current_user" do
            access_check(role, true, {:success => lambda{redirect_to(calendar_url)}}){post bookings_path, :booking => FactoryGirl.build(:booking, :user_id => @current_user.id).attributes}
          end

          it "creates bookings for other users" do
            access_check(role, true, {:success => lambda{redirect_to(calendar_url)}}){post bookings_path, :booking => FactoryGirl.build(:booking).attributes}
          end
        end
      end
    end

    describe "PUT /booking" do
      context "as an unprivileged user" do
        it "does update the own bookings" do
          access_check(:unprivileged, true, {:success => lambda{redirect_to(calendar_url)}}){put booking_path(FactoryGirl.create(:booking, :user_id => @current_user.id))}
        end

        it "does not update the bookings of others" do
          access_check(:unprivileged, false){put booking_path(FactoryGirl.create(:booking))}
        end
      end

      [:teaching, :admin].each do |role|
        context "as an #{role} user" do
          it "does update the own bookings" do
            access_check(role, true, {:success => lambda{redirect_to(calendar_url)}}){put booking_path(FactoryGirl.create(:booking, :user_id => @current_user.id))}
          end

          it "does  update the bookings of others" do
            access_check(role, true, {:success => lambda{redirect_to(calendar_url)}}){put booking_path(FactoryGirl.create(:booking))}
          end
        end
      end
    end

    describe "DELETE /booking" do
      context "as an unprivileged user" do
        it "does delete the own bookings" do
          access_check(:unprivileged, true, {:success => lambda{redirect_to(calendar_url)}}){delete booking_path(FactoryGirl.create(:booking, :user_id => @current_user.id))}
        end

        it "does not delete the bookings of others" do
          access_check(:unprivileged, false){delete booking_path(FactoryGirl.create(:booking))}
        end
      end

      [:teaching, :admin].each do |role|
        context "as an #{role} user" do
          it "does delete the own bookings" do
            access_check(role, true, {:success => lambda{redirect_to(calendar_url)}}){delete booking_path(FactoryGirl.create(:booking, :user_id => @current_user.id))}
          end

          it "does delete the bookings of others" do
            access_check(role, true, {:success => lambda{redirect_to(calendar_url)}}){delete booking_path(FactoryGirl.create(:booking))}
          end
        end
      end
    end
  end
end
