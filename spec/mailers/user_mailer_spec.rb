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
      @mail.from.should == @admin.mail_name 
    end

    it "has the address of the user" do
      @mail.to.should == @user.mail_name
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
        body.should have_content(edit_password_url(@user))
        body.should have_content(@user.reset_password_token)
        body.should contain(new_user_session_url)
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
      @mail.from.should == @admin.mail_name 
    end

    it "has the address of the user" do
      @mail.to.should == @user.mail_name
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
      @mail.from.should == @admin.mail_name 
    end

    it "has the address of the user" do
      @mail.to.should == @user.mail_name
    end

    it "has the approval change subject" do
      @mail.subject.should == I18n.t('user_mailer.destroy_mail.subject')
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
      @user = FactoryGirl.create(:approved_user)
      @admin = FactoryGirl.create(:admin_user)
      @mail = UserMailer.sign_up_notification(@user)
    end

    it "has the correct sender" do
      pending 'after cancan integration'
      @mail.from.should == 'timit@physchem.uni-freiburg.de'
    end

    it "has the address of all admins" do
      pending 'after cancan integration'
      @mail.to.should == @admins.join(', ')
    end

    it "has the approval change subject" do
      pending 'after cancan integration'
      @mail.subject.should == I18n.t('user_mailer.sign_up_notification.subject')
    end

    it "has the right encoding" do
      pending 'after cancan integration'
      @mail.charset.should == 'UTF-8'
    end

    it "comes as multipart email" do
      pending 'after cancan integration'
      @mail.content_type.should contain('multipart/alternative')
    end

    it "has a destroy body" do
      pending 'after cancan integration'
      @mail.parts.each do |body|
        body.should have_content(@user.user_name)
        #TODO: andere Inhalte
      end
    end
  end
end
