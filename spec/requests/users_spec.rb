require 'spec_helper'

describe "Users" do
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

  context "with login" do
    before :all do
      @user = FactoryGirl.create :approved_user
    end

    after :all do
      @user.destroy
    end

    before :each do
      post user_session_path, :user => {:email => @user.email, :password => 'password'}
    end

    describe "GET index" do
      it "renders index page" do
        get users_path
        response.should render_template('index')
        response.status.should == 200
        response.body.should include(@user.email)
        response.body.should have_selector(:a, :href => new_user_path)
        response.body.should have_selector(:a, :href => edit_user_path(@user))
        response.body.should have_selector(:a, :href => user_path(@user), :'data-method' => 'delete')
      end
    end

    describe "GET new" do
      it "rendes a new user form" do
        get new_user_path
        response.should render_template :new
        response.should render_template '_form'
        response.body.should have_selector(:input, :id => "user_email", :value => '')
        response.body.should_not have_selector(:input, :id => "user_password")
        response.body.should have_selector(:input, :type => "submit", :name => "commit")
        response.body.should have_selector(:a, :href => users_path)
      end
    end

    describe "POST create" do
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

    describe "GET edit" do
      it "renders the user edit form" do
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
      context "success" do
        it "redirects to index" do
          put user_path(@user = FactoryGirl.create(:user), :email => 'test@test.test')
          response.should redirect_to(users_path)
        end

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
