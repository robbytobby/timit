require 'spec_helper'

describe "Registrations" do
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
  end

end
