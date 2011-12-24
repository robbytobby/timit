require 'spec_helper'

describe MachinesController do
  include Devise::TestHelpers

  def valid_attributes
    FactoryGirl.attributes_for(:machine)
  end
  
  before :each do
    @machine = FactoryGirl.create(:machine)
    @machines = FactoryGirl.create_list(:machine, 3)
  end

  context "without user logged in" do
    describe "GET index" do
      it "redirect to login page" do
        get :index
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "GET show" do
      it "redirect to login page" do
        get :show, :id => @machine.id.to_s
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "GET new" do
      it "redirect to login page" do
        get :new
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "GET edit" do
      it "redirect to login page" do
        get :edit, :id => @machine.id.to_s
        response.should redirect_to(new_user_session_path)
      end
    end
  
    describe "POST create" do
      it "redirect to login page" do
        expect {
          post :create, :machine => valid_attributes
        }.not_to change(Machine, :count)
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "PUT update" do
      it "redirect to login page" do
        Machine.any_instance.should_not_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @machine.id, :machine => {'these' => 'params'}
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "DELETE destroy" do
      it "redirect to login page" do
        expect {
          delete :destroy, :id => @machine.id.to_s
        }.not_to change(Machine, :count).by(-1)
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  context "with user logged in" do
    before :each do
      sign_in FactoryGirl.create(:admin_user)
    end

    describe "GET index" do
      it "assigns all machines as @machines" do
        get :index
        assigns(:machines).should == Machine.order(:name).all
      end
    end
  
    describe "GET show" do
      it "assigns the requested machine as @machine" do
        get :show, :id => @machine.id.to_s
        assigns(:machine).should eq(@machine)
      end
    end
  
    describe "GET new" do
      it "assigns a new machine as @machine" do
        get :new
        assigns(:machine).should be_a_new(Machine)
      end
    end
  
    describe "GET edit" do
      it "assigns the requested machine as @machine" do
        get :edit, :id => @machine.id.to_s
        assigns(:machine).should eq(@machine)
      end
    end
  
    describe "POST create" do
      describe "with valid params" do
        it "creates a new Machine" do
          expect {
            post :create, :machine => valid_attributes
          }.to change(Machine, :count).by(1)
        end
  
        it "assigns a newly created machine as @machine" do
          post :create, :machine => valid_attributes
          assigns(:machine).should be_a(Machine)
          assigns(:machine).should be_persisted
        end
  
        it "redirects to the created machine" do
          post :create, :machine => valid_attributes
          response.should redirect_to(machines_path)
        end
      end
  
      describe "with invalid params" do
        it "assigns a newly created but unsaved machine as @machine" do
          # Trigger the behavior that occurs when invalid params are submitted
          Machine.any_instance.stub(:save).and_return(false)
          post :create, :machine => {}
          assigns(:machine).should be_a_new(Machine)
        end
  
        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Machine.any_instance.stub(:save).and_return(false)
          post :create, :machine => {}
          response.should render_template("new")
        end
      end
    end
  
    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested machine" do
          # Assuming there are no other machines in the database, this
          # specifies that the Machine created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Machine.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => @machine.id, :machine => {'these' => 'params'}
        end
  
        it "assigns the requested machine as @machine" do
          put :update, :id => @machine.id, :machine => valid_attributes
          assigns(:machine).should eq(@machine)
        end
  
        it "redirects to the machine" do
          put :update, :id => @machine.id, :machine => valid_attributes
          response.should redirect_to(machines_path)
        end
      end
  
      describe "with invalid params" do
        it "assigns the machine as @machine" do
          # Trigger the behavior that occurs when invalid params are submitted
          Machine.any_instance.stub(:save).and_return(false)
          put :update, :id => @machine.id.to_s, :machine => {}
          assigns(:machine).should eq(@machine)
        end
  
        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Machine.any_instance.stub(:save).and_return(false)
          put :update, :id => @machine.id.to_s, :machine => {}
          response.should render_template("edit")
        end
      end
    end
  
    describe "DELETE destroy" do
      it "destroys the requested machine" do
        expect {
          delete :destroy, :id => @machine.id.to_s
        }.to change(Machine, :count).by(-1)
      end
  
      it "redirects to the machines list" do
        delete :destroy, :id => @machine.id.to_s
        response.should redirect_to(machines_url)
      end
    end

  end
end
