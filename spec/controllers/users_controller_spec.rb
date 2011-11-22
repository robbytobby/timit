require 'spec_helper'

describe UsersController do
  include Devise::TestHelpers

  def valid_attributes
    FactoryGirl.build(:user).attributes.symbolize_keys
  end

  before :each do
    sign_in(@current_user = FactoryGirl.create(:approved_user))
    @user = FactoryGirl.create(:user)
  end

  describe "GET index" do
    it "assigns all users as @users" do
      get :index
      assigns(:users).should eq([@current_user, @user])
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      get :show, :id => @user.id.to_s
      assigns(:user).should eq(@user)
    end
  end

  describe "GET new" do
    it "assigns a new user to @user" do
      get :new
      assigns(:user).should be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns the user as @user" do
      get :edit, :id => @user
      assigns(:user).should eq(@user)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the user as @user" do
        put :update, :id => @user, :user => {:email => 'test@test.test'}
        assigns(:user).should eq(@user)
      end

      it "changes the user" do
        User.any_instance.should_receive(:update_attributes).with({"email" => 'test@test.test'})
        put :update, :id => @user, :user => {:email => 'test@test.test'}
      end

      it "redirects to index" do
        put :update, :id => @user, :user => {:email => 'test@test.test'}
        response.should redirect_to(users_path)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        put :update, :id => @user, :user => {:email => 'newmail'}
        assigns(:user).should eq(@user)
      end
      
      it "does not change the user" do 
        old_email = @user.email
        put :update, :id => @user, :user => {:email => 'newmail'}
        @user.reload.email.should eq(old_email)
      end
      
      it "re-renders eit" do
        put :update, :id => @user, :user => {:email => 'newmail'}
        response.should render_template :edit
      end
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "redirects to index" do
        post :create, :user => valid_attributes
        response.should redirect_to users_path
      end

      it "creates a new User" do
        expect {
          post :create, :user => valid_attributes
        }.to change(User, :count).by(1)
      end

      it "assigns the new user to @user" do
        post :create, :user => user_attr = valid_attributes
        assigns(:user).email == user_attr[:email]
      end

      it "sets an automatically generated password" do
        post :create, :user => user_attr = valid_attributes
        assigns(:user).encrypted_password.should_not be_blank
      end

      it "sends a welcom email to the user" do
        User.any_instance.should_receive(:send_welcome_email)
        post :create, :user => valid_attributes
      end
    end

    context "with invalid params" do
      it "re-renders new" do
        post :create, :user => {}
        response.should render_template :new
      end

      it "does not save the user" do
        expect {
          post :create, :user => {}
        }.not_to change(User, :count)
      end
    end
  end
end
