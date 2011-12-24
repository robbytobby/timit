require "spec_helper"

describe AccessoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/accessories").should route_to("accessories#index")
    end

    it "routes to #new" do
      get("/accessories/new").should route_to("accessories#new")
    end

    it "routes to #show" do
      get("/accessories/1").should route_to("accessories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/accessories/1/edit").should route_to("accessories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/accessories").should route_to("accessories#create")
    end

    it "routes to #update" do
      put("/accessories/1").should route_to("accessories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/accessories/1").should route_to("accessories#destroy", :id => "1")
    end

  end
end
