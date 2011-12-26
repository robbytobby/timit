require 'spec_helper'

describe AccessoriesController do
  include Devise::TestHelpers

  def valid_attributes
    FactoryGirl.attributes_for(:accessory)
  end

  before :each do
    sign_in FactoryGirl.create :admin_user
    @accessory = FactoryGirl.create(:accessory)
  end

  describe "GET index" do
    it "assigns all accessories as @accessories" do
      get :index
      assigns(:accessories).should eq([@accessory])
    end
  end

  describe "GET show" do
    it "assigns the requested accessory as @accessory" do
      get :show, :id => @accessory.id
      assigns(:accessory).should eq(@accessory)
    end
  end

  describe "GET new" do
    it "assigns a new accessory as @accessory" do
      get :new
      assigns(:accessory).should be_a_new(Accessory)
    end
  end

  describe "GET edit" do
    it "assigns the requested accessory as @accessory" do
      get :edit, :id => @accessory.id
      assigns(:accessory).should eq(@accessory)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Accessory" do
        expect {
          post :create, :accessory => valid_attributes
        }.to change(Accessory, :count).by(1)
      end

      it "assigns a newly created accessory as @accessory" do
        post :create, :accessory => valid_attributes
        assigns(:accessory).should be_a(Accessory)
        assigns(:accessory).should be_persisted
      end

      it "redirects to the accessory index" do
        post :create, :accessory => valid_attributes
        response.should redirect_to(accessories_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved accessory as @accessory" do
        # Trigger the behavior that occurs when invalid params are submitted
        Accessory.any_instance.stub(:save).and_return(false)
        post :create, :accessory => {}
        assigns(:accessory).should be_a_new(Accessory)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Accessory.any_instance.stub(:save).and_return(false)
        post :create, :accessory => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested accessory" do
        # Assuming there are no other accessories in the database, this
        # specifies that the Accessory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Accessory.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @accessory.id, :accessory => {'these' => 'params'}
      end

      it "assigns the requested accessory as @accessory" do
        put :update, :id => @accessory.id, :accessory => valid_attributes
        assigns(:accessory).should eq(@accessory)
      end

      it "redirects to the accessory index" do
        put :update, :id => @accessory.id, :accessory => valid_attributes
        response.should redirect_to(accessories_path)
      end
    end

    describe "with invalid params" do
      it "assigns the accessory as @accessory" do
        # Trigger the behavior that occurs when invalid params are submitted
        Accessory.any_instance.stub(:save).and_return(false)
        put :update, :id => @accessory.id, :accessory => {}
        assigns(:accessory).should eq(@accessory)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Accessory.any_instance.stub(:save).and_return(false)
        put :update, :id => @accessory.id, :accessory => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested accessory" do
      accessory = Accessory.create! valid_attributes
      expect {
        delete :destroy, :id => accessory.id
      }.to change(Accessory, :count).by(-1)
    end

    it "redirects to the accessories list" do
      accessory = Accessory.create! valid_attributes
      delete :destroy, :id => accessory.id
      response.should redirect_to(accessories_url)
    end
  end

end
