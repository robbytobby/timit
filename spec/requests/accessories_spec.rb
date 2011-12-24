require 'spec_helper'

describe "Accessories" do
  def session_for(role)
    @current_user = FactoryGirl.create "#{role}_user".to_sym, :approved => true
    post user_session_path, :user => {:email => @current_user.email, :password => 'password'}
  end

  describe "GET /accessories" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      session_for :unprivileged
      get accessories_path
      response.status.should be(200)
    end
  end
end
