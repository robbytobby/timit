require 'spec_helper'

describe ApplicationController do
  include Devise::TestHelpers

  describe "after_sign_out_path" do
    it "leads to login" do
      self.controller.send(:after_sign_out_path_for, User).should == new_user_session_path
    end
  end

  describe "after_sign_in_path_for" do
    after :all do
      I18n.locale = :de
    end

    it "set the default locale for a user" do
      @user = FactoryGirl.create(:approved_user)
      @user.locale = 'pt'
      self.controller.send(:after_sign_in_path_for, @user)
      I18n.locale.should == :pt
    end
  end
end
