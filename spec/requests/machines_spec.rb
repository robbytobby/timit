require 'spec_helper'

describe "Machines" do
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

  context "without login" do
    describe "GET /machines" do
      it "redirects to login path" do
        get machines_path 
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "GET /machine/new" do
      it "redirects to login path" do
        get new_machine_path
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "GET /machine/edit" do
      it "redirects to login path" do
        get edit_machine_path(FactoryGirl.create(:machine))
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "post /machines" do
      it "redirects to login path" do
        post machines_path :booking => FactoryGirl.build(:machine)
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "put /bookings" do
      it "redirects to login path" do
        put machine_path FactoryGirl.create(:machine) 
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "delete /booking" do
      it "redirects to login path" do
        delete machine_path FactoryGirl.create(:machine) 
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  ### As User
  context "with login" do
    describe "GET /machines" do
      before :each do
        @machines = FactoryGirl.create_list(:machine, 2)
      end

      User.roles.each do |role|
        it "shows index for anybody" do
          access_check(role, true){get machines_path}
        end
      end
      
      it "has the right content"

      [:unprivileged, :teaching].each do |role|
        it "does not show new, edit and destroy links for #{role} users" do
          session_for role
          get machines_path
          response.should render_template(:index)
          response.body.should_not have_selector(:a, :href => edit_machine_path(@machines.first))
          response.body.should_not have_selector(:a, :href => machine_path(@machines.first), 'data-method' => 'delete')
        end
      end

      it "does show, edit and destroy links for admin users" do
        session_for :admin
        get machines_path 
        response.should render_template(:index)
        response.body.should have_selector(:a, :href => edit_machine_path(@machines.first))
        response.body.should have_selector(:a, :href => machine_path(@machines.first), 'data-method' => 'delete')
      end
    end

    describe "GET show" do
      before :each do
        @machine = FactoryGirl.create(:machine)
      end

      it "shows the machine for all users" do
        User.roles.each{|r| access_check(r, true){get machine_path(@machine)} }
      end

      it "shows the right content"
    end

    describe "GET new" do
      [:unprivileged, :teaching].each do |role|
        it "does not show the new booking form for #{role} users" do
          access_check(role, false){get new_machine_path}
        end
      end

      it "does show the new booking form for admin users" do
        access_check(:admin, true){get new_machine_path} 
      end

      it "shows the right content"
    end

    describe "GET edit" do
      before :each do
        @machine = FactoryGirl.create(:machine)
      end

      [:unprivileged, :teaching].each do |role|
        it "does not show the edit booking form for #{role} users" do
          access_check(role, false){get edit_machine_path @machine}
        end
      end

      it "does show the edit booking form for admin users" do
        access_check(:admin, true){get edit_machine_path @machine}
      end
    end

    describe "POST /machines" do
      [:unprivileged, :teaching].each do |role|
        context "as a #{role} user" do
          it "does not create machines" do
            access_check(role, false){post machines_path, :machine => FactoryGirl.build(:machine).attributes}
          end
        end
      end
      
      context "as an admin user" do
        it "does create machines" do
          access_check(:admin, true, :success => lambda{redirect_to machines_path}){post machines_path, :machine => FactoryGirl.build(:machine).attributes}
        end

        it "has the right content"
      end
    end

    describe "PUT /machine" do
      [:unprivileged, :teaching].each do |role|
        context "as a #{role} user" do
          it "does not update machines" do
            access_check(role, false){put machine_path FactoryGirl.create(:machine).attributes }
          end
        end
      end
      
      context "as an admin user" do
        it "does update machines" do
          access_check(:admin, true, :success => lambda{redirect_to machines_path}){put machine_path FactoryGirl.create(:machine) }
        end

        it "has the right content"
      end
    end

    describe "DELETE /machine" do
      [:unprivileged, :teaching].each do |role|
        context "as a #{role} user" do
          it "does not delete machines" do
            access_check(role, false){delete machine_path FactoryGirl.create(:machine).attributes }
          end
        end
      end
      
      context "as an admin user" do
        it "does delete machines" do
          access_check(:admin, true, :success => lambda{redirect_to machines_path}){delete machine_path FactoryGirl.create(:machine) }
        end

        it "has the right content"
      end
    end
  end
end


