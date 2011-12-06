require 'spec_helper'
require 'cancan/matchers'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user, :approved => false)
  end

  it "has a defined set of roles" do
    User.roles.should == [ "unprivileged", "teaching", "admin" ]
  end

  it "needs to be approved before being able to sign in" do
    @user.should_not be_active_for_authentication

    @user = FactoryGirl.create(:user, :approved => true)
    @user.should be_active_for_authentication
  end

  subject{ FactoryGirl.create(:user, :approved => false) }
  it { should_not accept_values_for(:first_name, nil, '', ' ') }
  it { should_not accept_values_for(:last_name, nil, '', ' ') }
  it { should_not accept_values_for(:phone, nil, '', ' ', '1a3', 'abc') }
  it { should_not accept_values_for(:role, nil, '', ' ') }
  it { should accept_values_for(:role, 'unprivileged', 'teaching', 'admin') }
  it { should_not accept_values_for(:role, 'test', 'blah', 'gotcha')}
  its(:name) { should == @user.first_name + ' ' + @user.last_name }

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

  describe "role admin" do
    before :each do
      @user = FactoryGirl.create(:admin_user) 
      @ability = Ability.new(@user)
    end

    it "should be able to manage everything" do
      @ability.should be_able_to(:manage, :all)
    end
  end

  describe "in role teaching" do
    before :each do
      @user = FactoryGirl.create(:teaching_user) 
      @ability = Ability.new(@user)
    end

    it "should be able to manage Bookings" do
      @ability.should be_able_to(:manage, Booking)
    end

    it "should not be able to :manage other users" do
      other_user = FactoryGirl.create(:user)
      @ability.should_not be_able_to :manage, other_user
    end

    it "should be able to manage itself" do
      @ability.should be_able_to :update, @user
      @ability.should be_able_to :destroy, @user
    end

    it "should not be able to change its role" do
      @ability.should_not be_able_to :change_role, @user
    end

    it "should be able to :read everything" do
      @ability.should be_able_to :read, :all
    end

    it "should not be able to manage machines" do
      @ability.should_not be_able_to :manage, Machine
    end
  end

  describe "in role unprivileged" do
    before :each do
      @user = FactoryGirl.create(:unprivileged_user) 
      @ability = Ability.new(@user)
    end

    it "should not be able to manage Bookings of others" do
      other_booking = FactoryGirl.create(:booking)
      @ability.should_not be_able_to(:manage, other_booking)
    end

    it "should be able to manage it's own bookings" do
      own_booking = FactoryGirl.create(:booking, :user => @user)
      @ability.should be_able_to :create, Booking, :user_id => @user.id
      @ability.should be_able_to :update, own_booking
      @ability.should be_able_to :destroy, own_booking
    end

    it "should not be able to :manage other users" do
      other_user = FactoryGirl.create(:user)
      @ability.should_not be_able_to :manage, other_user
    end

    it "should be able to manage itself" do
      @ability.should be_able_to :update, @user
      @ability.should be_able_to :destroy, @user
    end
    
    it "should not be able to change its role" do
      @ability.should_not be_able_to :change_role, @user
    end

    it "should not be able to manage machines" do
      @ability.should_not be_able_to :manage, Machine
    end

    it "should be able to :read everything" do
      @ability.should be_able_to :read, :all
    end

  end
end
