require 'spec_helper'

describe "Users" do
  def session_for(role)
    @current_user = FactoryGirl.create "#{role}_user".to_sym, :approved => true
    post user_session_path, :user => {:email => @current_user.email, :password => 'password'}
  end

  def access_check(role, success, &block)
    session_for role
    yield
    if success
      response.status.should == 200
    else
      response.should redirect_to(root_url)
    end
  end

  ### Anonymus
  context "without login" do
    describe "GET index" do
      it "redirects to login" do
        get users_path
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "GET edit" do
      it "redirects to login" do
        get edit_user_path(@user = FactoryGirl.create(:user))
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "GET new" do
      it "redirects to login" do
        get new_user_path
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "POST create" do
      it "redirects to login" do
        post users_path
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  ### As User
  context "with login" do
    describe "GET index" do
      it "should be accessable for anybody" do
        User.roles.each{ |role| access_check(role, true){get users_path} }
      end

      it "renders index page" do
        session_for :unprivileged
        @user = FactoryGirl.create :approved_user
        get users_path
        response.should render_template('index')
        response.body.should include(@user.email)
        response.body.should have_selector(:a, :href => new_user_path)
        response.body.should have_selector(:a, :href => edit_user_path(@user))
        response.body.should have_selector(:a, :href => user_path(@user), :'data-method' => 'delete')
      end
    end

    describe "GET new" do
      it "should not be accessible for all but admins" do
        (User.roles - ['admin']).each{ |role| access_check(role, false){get new_user_path} }
      end

      it "should be accessible for admins" do
        access_check(:admin, true){get new_user_path} 
      end

      context "as authorized user" do
        before :each do
          session_for :admin
        end

        it "renders a new user form" do
          get new_user_path
          response.should render_template :new
          response.should render_template '_form'
          response.body.should have_selector(:input, :id => "user_email", :value => '')
          response.body.should_not have_selector(:input, :id => "user_password")
          response.body.should have_selector(:input, :type => "submit", :name => "commit")
          response.body.should have_selector(:a, :href => users_path)
        end

        it "renders a role select field if the current user is an admin" do
          get new_user_path
          response.body.should have_selector(:select, :id => 'user_role')
        end
      end
    end

    describe "POST create" do
      it "should not be accessible for all but admins" do
        (User.roles - ['admin']).each{ |role| access_check(role, false){post users_path :user => FactoryGirl.build(:user).attributes.symbolize_keys} }
      end

      it "should be accessible for admins" do
        session_for :admin
        post users_path :user => FactoryGirl.build(:user).attributes.symbolize_keys
        response.should redirect_to(users_url)
      end

      context "as authorized user" do
        before :each do
          session_for :admin
        end

        context "with valid params" do
          it "redirects to index" do
            post users_path :user => FactoryGirl.build(:user).attributes.symbolize_keys
            response.should redirect_to users_path
          end
        end

        context "with invalid params" do
          it "re-renders new" do
            post users_path :user => FactoryGirl.attributes_for(:user, :email => '')
            response.should render_template :new
          end
        end
      end
    end

    describe "GET edit" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "should not be accessible for all but admins" do
        (User.roles - ['admin']).each{ |role| access_check(role, false){get edit_user_path(@user)} }
      end

      it "should be accessible for admins" do
        access_check(:admin, true){get edit_user_path(@user)} 
      end

      it "renders the user edit form" do
        session_for :admin
        get edit_user_path(@user = FactoryGirl.create(:user))
        response.status.should == 200
        response.should render_template(:edit)
        response.body.should include(@user.email)
        response.body.should include(I18n.t('users.edit.heading', :name => @user.user_name))
        response.body.should have_selector(:input, :id => "user_email", :value => @user.email)
        response.body.should have_selector(:input, :type => "submit", :name => "commit")
        response.body.should have_selector(:a, :href => users_path)
      end
    end

    describe "PUT update" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "should not be accessible for all but admins" do
        (User.roles - ['admin']).each{ |role| access_check(role, false){put user_path(@user, :user =>{:email => 'test@test.test'})} }
      end

      it "should be accessible for admins" do
        session_for :admin
        put user_path(@user = FactoryGirl.create(:user), :user =>{:email => 'test@test.test'})
        response.should redirect_to(users_path)
      end

      context "as authorized user" do
        before :each do
          session_for :admin
        end

        context "success" do
          it "changes the user" do
            put user_path(@user = FactoryGirl.create(:user), :user =>{:email => 'test@test.test'})
            @user.reload.email.should == 'test@test.test'
          end
        end

        context "no success" do
          it "renders edit form" do
            put user_path(@user = FactoryGirl.create(:user), :user =>{:email => ''})
            response.should render_template(:edit)
          end

          it "does not change the user" do
            put user_path(@user = FactoryGirl.create(:user), :user =>{:email => ''})
            @user.reload.email.should_not be_blank
          end
        end
      end
    end
  end
end
