require 'spec_helper'

describe RegistrationsController do
  include Devise::TestHelpers

  #This feels a bit hackish, but solves a problem with "Could not find devise mapping for path..."
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "create" do
    context "success" do
      it "sends a mail to the admin about an inactive account" do
        @user = FactoryGirl.build(:user)
        User.stub(:find_by_email => @user)
        UserMailer.stub(:sign_up_notification => @mail = mock(Mail, :deliver => true))
        UserMailer.should_receive(:sign_up_notification).with(@user)
        post :create
      end
    end

    context "failure" do
      it "does not send a mail to the admin" do
        @user = FactoryGirl.build(:user)
        User.stub(:find_by_email => nil)
        UserMailer.stub(:sign_up_notification => @mail = mock(Mail, :deliver => true))
        UserMailer.should_not_receive(:sign_up_notification)
        post :create
      end
    end
  end
end

