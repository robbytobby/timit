require 'spec_helper'

describe CalendarController do
  describe "GET index" do
    it "assigns a new calendar" do
      params = {:start_date => Date.today.to_s, :end_date => (Date.today + 4.weeks).to_s}
      Calendar.should_receive(:new).with(params[:start_date], params[:end_date], nil)
      get :index, params
    end
  end
end
