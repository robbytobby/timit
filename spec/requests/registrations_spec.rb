require 'spec_helper'

describe "Registrations" do
  before :all do
    FactoryGirl.create(:admin_user)
  end

  describe "POST /users" do
    it "returns to new registration on failure" do
      post user_registration_path
      response.should render_template("registrations/new")
    end

    it "does not allow to self activate" do
      post user_registration_path, :user =>  user = FactoryGirl.attributes_for(:user, :approved => true)
      response.should redirect_to(new_user_session_path)
      User.find_by_email(user[:email]).should_not be_approved
    end
    
    it "redirects to new session on susscess" do
      post user_registration_path, :user => FactoryGirl.attributes_for(:user)
      response.should redirect_to(new_user_session_path)
    end

    it "should be okay with first_name, last_name, phone, email and password" do
      # If this fails, go and add the necessary fields to app/views/registrations/new
      params = { :user => { first_name: 'First', last_name: 'Last', phone: '203', email: 'w@w.w', password: 'geheim', password_confirmation: 'geheim'}}
      expect{
        post user_registration_path, params
      }.to change(User, :count).by(1)
    end
  end

end
