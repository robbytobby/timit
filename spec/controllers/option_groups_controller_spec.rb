require 'spec_helper'
describe OptionGroupsController do
  include Devise::TestHelpers

  before :each do
    @option_group = FactoryGirl.create(:option_group)
  end

  def valid_attributes
    FactoryGirl.attributes_for(:option_group)
  end

  context "with non-admin user logged in" do
    before :each do
      sign_in FactoryGirl.create(:approved_user)
    end

    describe "GET index" do
      it "assigns all option_groups as @option_groups" do
        get :index
        assigns(:option_groups).should eq([@option_group])
      end
    end

    describe "GET show" do
      it "assigns the requested option_group as @option_group" do
        get :show, :id => @option_group.id
        assigns(:option_group).should eq(@option_group)
      end
    end

    describe "GET new" do
      it "assigns a new option_group as @option_group" do
        get :new
        redirect_to calendar_path
      end
    end
  end

  context "with user logged in" do
    before :each do
      sign_in FactoryGirl.create(:admin_user)
    end

    describe "GET new" do
      it "assigns a new option_group as @option_group" do
        get :new
        assigns(:option_group).should be_a_new(OptionGroup)
      end
    end

    describe "GET edit" do
      it "assigns the requested option_group as @option_group" do
        option_group = OptionGroup.create! valid_attributes
        get :edit, :id => option_group.id
        assigns(:option_group).should eq(option_group)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new OptionGroup" do
          expect {
            post :create, :option_group => valid_attributes
          }.to change(OptionGroup, :count).by(1)
        end

        it "assigns a newly created option_group as @option_group" do
          post :create, :option_group => valid_attributes
          assigns(:option_group).should be_a(OptionGroup)
          assigns(:option_group).should be_persisted
        end

        it "redirects to the created option_group" do
          post :create, :option_group => valid_attributes
          response.should redirect_to(option_groups_path)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved option_group as @option_group" do
          # Trigger the behavior that occurs when invalid params are submitted
          OptionGroup.any_instance.stub(:save).and_return(false)
          post :create, :option_group => {}
          assigns(:option_group).should be_a_new(OptionGroup)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          OptionGroup.any_instance.stub(:save).and_return(false)
          post :create, :option_group => {}
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested option_group" do
          option_group = OptionGroup.create! valid_attributes
          # Assuming there are no other option_groups in the database, this
          # specifies that the OptionGroup created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          OptionGroup.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => option_group.id, :option_group => {'these' => 'params'}
        end

        it "assigns the requested option_group as @option_group" do
          option_group = OptionGroup.create! valid_attributes
          put :update, :id => option_group.id, :option_group => valid_attributes
          assigns(:option_group).should eq(option_group)
        end

        it "redirects to the option_group" do
          option_group = OptionGroup.create! valid_attributes
          put :update, :id => option_group.id, :option_group => valid_attributes
          response.should redirect_to(option_groups_path)
        end
      end

      describe "with invalid params" do
        it "assigns the option_group as @option_group" do
          option_group = OptionGroup.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          OptionGroup.any_instance.stub(:save).and_return(false)
          put :update, :id => option_group.id, :option_group => {}
          assigns(:option_group).should eq(option_group)
        end

        it "re-renders the 'edit' template" do
          option_group = OptionGroup.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          OptionGroup.any_instance.stub(:save).and_return(false)
          put :update, :id => option_group.id, :option_group => {}
          response.should render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested option_group" do
        option_group = OptionGroup.create! valid_attributes
        expect {
          delete :destroy, :id => option_group.id
        }.to change(OptionGroup, :count).by(-1)
      end

      it "redirects to the option_groups list" do
        option_group = OptionGroup.create! valid_attributes
        delete :destroy, :id => option_group.id
        response.should redirect_to(option_groups_url)
      end
    end
  end

end
