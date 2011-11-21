require 'spec_helper'

describe ApplicationController do
  include Devise::TestHelpers

  describe "after_sign_out_path" do
    it "leads to login" do
      self.controller.send(:after_sign_out_path_for, User).should == new_user_session_path
    end
  end
end
