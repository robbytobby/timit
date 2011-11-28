require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user, :approved => false)
  end

  it "needs to be approved before being able to sign in" do
    @user.should_not be_active_for_authentication

    @user = FactoryGirl.create(:user, :approved => true)
    @user.should be_active_for_authentication
  end

  describe "mail_name" do
    it "is the combination of user_name and email_address" do
      @user.mail_name.should == "#{@user.user_name} <#{@user.email}>"
    end
  end

  describe "send_welcome_email" do
    before(:each) do
      @admin = FactoryGirl.create(:admin_user)
    end

    it "generates a reset_password_token!" do
      @user.send_welcome_email(@admin)
      @user.reload.reset_password_token.should_not be_blank
    end
    
    it "sends an email" do
      @test = 'test'
      @test.stub(:deliver => true)
      UserMailer.stub(:welcome_email => @test)
      @test.should_receive(:deliver)
      @user.send_welcome_email(@admin)
    end
  end

  describe "toggle approved" do
    it "changes 'appoved' from true to false" do
      @user = FactoryGirl.create(:approved_user)
      @user.toggle_approved
      @user.should_not be_approved
    end

    it "changes 'appoved' from false to true" do
      @user.toggle_approved
      @user.should be_approved
    end
  end
end
