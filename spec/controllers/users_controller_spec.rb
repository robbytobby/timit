require 'spec_helper'

describe UsersController do
  include Devise::TestHelpers

  def valid_attributes
    FactoryGirl.build(:user).attributes.symbolize_keys
  end

  before :each do
    sign_in(@current_user = FactoryGirl.create(:admin_user))
    @user = FactoryGirl.create(:user)
  end

  describe "GET index" do
    it "assigns all users as @users" do
      get :index
      assigns(:users).should eq([@current_user, @user])
    end

    it "has filters e.q.'only not approved'"
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

      it "does not update somebody elses password" do
        put :update, :id => @user, :user => {:password => 'new_password'}
        @user.encrypted_password.should == @user.reload.encrypted_password
      end

      it "does not change own password" do
        put :update, :id => @current_user, :user => {:password => 'new_password'}
        @current_user.encrypted_password.should == @current_user.reload.encrypted_password
      end

      it "is possible to change the role - for admins" do
        put :update, :id => @user, :user => {:role => 'admin'}
        @user.reload.role.should == 'admin'
      end

      it "is not possible to chage the own role" do
        put :update, :id => @current_user, :user => {:role => 'unprivileged'}
        @current_user.reload.role.should == 'admin'
      end

      it "is not possible to change the role for non admin users" do
        sign_in(@current_user = FactoryGirl.create(:unprivileged_user))
        put :update, :id => @user, :user => {:role => 'admin'}
        @user.reload.role.should_not == 'admin'
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
      
      it "re-renders it" do
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

      it "creates an approved User" do
        @user = FactoryGirl.build(:user)
        post :create, :user => @user.attributes.symbolize_keys
        User.find_by_email(@user.email).should be_approved
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
        User.any_instance.should_receive(:send_welcome_email).with(@current_user)
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

  describe "destroy" do
    it "destroys the user" do
      user = @user
      expect {
        delete :destroy, :id => @user.id.to_s
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = @user
      delete :destroy, :id => user.id.to_s
      response.should redirect_to(users_url)
    end

    it "informes the user via email" do
      UserMailer.stub(:destroy_email => @mail = mock(Mail, :deliver => true)) 
      UserMailer.should_receive(:destroy_email).with(@user, @current_user)
      @mail.should_receive(:deliver)
      delete :destroy, :id => @user
    end

    it "does not delete the last admin" do
    end

    context "the current user" do
      it "does delete the current user" do
        expect{
          delete :destroy, :id => @current_user.id.to_s
        }.to change(User, :count)
      end

      it "redirects to login page" do
        delete :destroy, :id => @current_user.id.to_s
        response.should redirect_to(new_user_session_url)
      end

    end

  end

  describe "change approved" do
    it "changes the 'approved' value from false to true" do
      get :change_approved, :id => @user
      @user.reload.should be_approved
    end

    it "changes the 'approved' value from true to false" do
      @user = FactoryGirl.create(:approved_user)
      get :change_approved, :id => @user
      @user.reload.should_not be_approved
    end

    context "with approve only param" do
      it "changes the 'approved' value from false to true" do
        get :change_approved, :id => @user, :approve => true
        @user.reload.should be_approved
      end

      it "does not change the 'approved' value from true to false" do
        @user = FactoryGirl.create(:approved_user)
        get :change_approved, :id => @user, :approve => true
        @user.reload.should be_approved
        flash[:notice].should == I18n.t('controller.users.allready_approved')
      end
    end


    context "of current user" do
      it "does not change the account" do
        expect{
          get :change_approved, :id => @current_user.id.to_s
        }.not_to change(@current_user, :approved)
      end

      it "sends a note about not being able to change yoursef" do
        get :change_approved, :id => @current_user.id.to_s
        flash[:error].should_not be_empty
      end

      it "redirects to index" do
        get :change_approved, :id => @current_user.id.to_s
        response.should redirect_to(root_url)
      end
    end

    context "user could be saved" do
      it "informes the user via email" do
        UserMailer.stub(:approval_change_email => @mail = mock(Mail, :deliver => true)) 
        UserMailer.should_receive(:approval_change_email).with(@user, @current_user)
        @mail.should_receive(:deliver)
        get :change_approved, :id => @user
      end

      it "redirect to index with success notice" do
        get :change_approved, :id => @user
        response.should redirect_to users_url
        flash[:notice].should == I18n.t('controller.users.activation.success', :name => @user.user_name)

        get :change_approved, :id => @user
        response.should redirect_to users_url
        flash[:notice].should == I18n.t('controller.users.deactivation.success', :name => @user.user_name)
      end

    end

    context "user could not be saved" do
      before(:each) do
        @user.stub(:save => false)
        User.stub(:find => @user)
      end

      it "does not send an email" do
        UserMailer.stub(:approval_change_email => @mail = mock(Mail, :deliver => true)) 
        UserMailer.should_not_receive(:approval_change_email).with(@user, @current_user)
        @mail.should_not_receive(:deliver)
        get :change_approved, :id => @user
      end

      it "redirect to index with success notice" do
        get :change_approved, :id => @user
        response.should redirect_to users_url
        flash[:notice].should == I18n.t('controller.users.activation.failure', :name => @user.user_name)
      end
    end
  end
end
