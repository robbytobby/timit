require "spec_helper"

describe OptionGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/option_groups").should route_to("option_groups#index")
    end

    it "routes to #new" do
      get("/option_groups/new").should route_to("option_groups#new")
    end

    it "routes to #show" do
      get("/option_groups/1").should route_to("option_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/option_groups/1/edit").should route_to("option_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/option_groups").should route_to("option_groups#create")
    end

    it "routes to #update" do
      put("/option_groups/1").should route_to("option_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/option_groups/1").should route_to("option_groups#destroy", :id => "1")
    end

  end
end
