require "spec_helper"

describe UserMailer do
  before :each do
    #TODO das hier global lösen
    default_url_options[:host] = 'localhost:3000'
  end

  describe "welcome email" do
    before :each do
      @user = FactoryGirl.create(:user)
      @user.send(:generate_reset_password_token!)
      @admin = FactoryGirl.create(:admin_user)
      @mail = UserMailer.welcome_email(@user, @admin)
    end

    it "has the correct sender" do
      @mail.from.should contain(Devise.mailer_sender)
    end

    it "has the address of the user" do
      @mail.to.should contain(@user.email)
    end

    it "has the welcome subject" do
      @mail.subject.should == I18n.t('user_mailer.welcome_email.subject')
    end

    it "has the right encoding" do
      @mail.charset.should == 'UTF-8'
    end

    it "comes as multipart email" do
      @mail.content_type.should contain('multipart/alternative')
    end

    it "has a welcome body with link to set the password" do
      @mail.parts.each do |body|
        body.should have_content(@user.user_name)
      end
    end
  end

  describe "approval_change_email" do
    before :each do
      @user = FactoryGirl.create(:approved_user)
      @admin = FactoryGirl.create(:admin_user)
      @mail = UserMailer.approval_change_email(@user, @admin)
    end
    
    it "has the correct sender" do
      @mail.from.should contain(Devise.mailer_sender)
    end

    it "has the address of the user" do
      @mail.to.should contain(@user.email)
    end

    it "has the approval change subject" do
      @mail.subject.should == I18n.t('user_mailer.approval_change_email.subject')
    end

    it "has the right encoding" do
      @mail.charset.should == 'UTF-8'
    end

    it "comes as multipart email" do
      @mail.content_type.should contain('multipart/alternative')
    end

    it "has a welcome body with link to set the password" do
      @mail.parts.each do |body|
        body.should have_content(@user.user_name)
        #TODO: andere Inhalte
      end
    end
  end

  describe "destroy_email" do
    before :each do
      @user = FactoryGirl.create(:approved_user)
      @admin = FactoryGirl.create(:admin_user)
      @mail = UserMailer.destroy_email(@user, @admin)
    end
    
    it "has the correct sender" do
      @mail.from.should contain(Devise.mailer_sender)
    end

    it "has the address of the user" do
      @mail.to.should contain(@user.email)
    end

    it "has the approval change subject" do
      @mail.subject.should == I18n.t('user_mailer.destroy_email.subject')
    end

    it "has the right encoding" do
      @mail.charset.should == 'UTF-8'
    end

    it "comes as multipart email" do
      @mail.content_type.should contain('multipart/alternative')
    end

    it "has a destroy body" do
      @mail.parts.each do |body|
        body.should have_content(@user.user_name)
        #TODO: andere Inhalte
      end
    end
  end

  describe "sign_up_notification" do
    before :each do
      @user = FactoryGirl.create(:user)
      @admins = FactoryGirl.create_list(:admin_user, 2)
      @mail = UserMailer.sign_up_notification(@user)
    end

    it "has the correct sender" do
      @mail.from.should == [Devise.mailer_sender]
    end

    it "has the address of all admins" do
      @mail.to.should == @admins.map{|a| a.email}
    end

    it "has the approval change subject" do
      @mail.subject.should == I18n.t('user_mailer.sign_up_notification.subject')
    end

    it "has the right encoding" do
      @mail.charset.should == 'UTF-8'
    end

    it "comes as multipart email" do
      @mail.content_type.should contain('multipart/alternative')
    end

    it "has a sign up notification body" do
      @mail.parts.each do |body|
        body.should have_content(@user.user_name)
        #TODO: andere Inhalte
      end
    end
  end
end
