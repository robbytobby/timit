require 'spec_helper'
require 'cancan/matchers'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @approved_user = FactoryGirl.create(:user, :approved => true)
  end
  subject{@user}

  it {should have_many(:bookings).dependent(:destroy)}

  [:first_name, :last_name, :phone, :email, :password_confirmation, :password_confirmation, :remember_me].each do |attr|
    it {should allow_mass_assignment_of(attr)}
  end

  (User.attribute_names.map{|a| a.to_sym} - [:first_name, :last_name, :phone, :email, :password_confirmation, :password_confirmation, :remember_me]).each do |attr|
    it {should_not allow_mass_assignment_of(attr)}
  end

  it "has a defined set of roles" do
    User.roles.should == [ "unprivileged", "teaching", "admin" ]
  end

  describe "needs to be approved before being able to sign in" do
    it { should_not be_active_for_authentication}
    it { @approved_user.should be_active_for_authentication}
  end

  describe "inactive_message" do
    its(:inactive_message){should == :not_approved}
    it{ @approved_user.inactive_message.should == :inactive}
  end

  it { should_not accept_values_for(:first_name, nil, '', ' ') }
  it { should_not accept_values_for(:last_name, nil, '', ' ') }
  it { should_not accept_values_for(:phone, nil, '', ' ', '1a3', 'abc') }
  it { should_not accept_values_for(:role, nil, '', ' ') }
  it { should accept_values_for(:role, 'unprivileged', 'teaching', 'admin') }
  it { should_not accept_values_for(:role, 'test', 'blah', 'gotcha')}
  its(:name) { should == @user.first_name + ' ' + @user.last_name }

  its(:mail_name){should== "#{@user.user_name} <#{@user.email}>"}
  its(:user_name){should == @user.name}

  it "has a short user name" do
    @user.user_name(:short).should ==  @user.first_name[0] + '. ' + @user.last_name[0..15]
  end
  
  it "raises an error if user_name gets an unknown format" do
    lambda{@user.user_name(:bla)}.should raise_error
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
    subject{Ability.new(FactoryGirl.create(:admin_user))}
    it { should be_able_to(:manage, :all) }
  end

  describe "in role teaching" do
    before(:each){@user = FactoryGirl.create(:teaching_user)}
    subject{Ability.new(@user)}

    it {should be_able_to(:manage, Booking)}
    it {should_not be_able_to(:manage, FactoryGirl.create(:user))}
    it {should be_able_to(:update, @user)}
    it {should be_able_to(:destroy, @user)}
    it {should_not be_able_to(:change_role, @user)}
    it {should be_able_to(:read, :all)}
    it {should_not be_able_to(:manage, Machine)}
  end

  describe "in role unprivileged" do
    before(:each){@user = FactoryGirl.create(:unprivileged_user)}
    subject{Ability.new(@user)}

    it {should_not be_able_to(:manage, FactoryGirl.create(:booking))}
    it {should be_able_to(:create, Booking, :user_id => @user.id)}
    it {should be_able_to(:update, FactoryGirl.create(:booking, :user => @user))}
    it {should be_able_to(:destroy, FactoryGirl.create(:booking, :user => @user))}
    it {should_not be_able_to(:manage, @approved_user)}
    it {should be_able_to(:update, @user)}
    it {should be_able_to(:destroy, @user)}
    it {should_not be_able_to(:change_role, User)}
    it {should_not be_able_to(:manage, Machine)}
    it {should be_able_to(:read, :all)}
  end
end
