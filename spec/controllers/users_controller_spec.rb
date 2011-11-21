require 'spec_helper'

describe UsersController do
  include Devise::TestHelpers

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

  describe "GET edit" do
    it "assigns the user as @user" do
      get :edit, :id => @user
      assigns(:user).should eq(@user)
    end
  end
end
